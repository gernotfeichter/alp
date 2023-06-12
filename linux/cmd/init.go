/*
Copyright © 2023 Gernot Feichter

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.
*/
package cmd

import (
	"bufio"
	"bytes"
	"fmt"
	"html/template"
	"io"
	"os"
	"strings"

	myfilepath "github.com/gernotfeichter/alp/filepath"
	"github.com/gernotfeichter/alp/ini"
	"github.com/gernotfeichter/alp/random"
	log "github.com/sirupsen/logrus"
	"github.com/spf13/cobra"
	"github.com/spf13/viper"
)

type InitArgs struct {
	Target  		[]string
	PamConfigFile 	[]string
}

var initArgs InitArgs

// initCmd represents the init command
var initCmd = &cobra.Command{
	Use:   "init",
	Short: "(re-) initialize alp",
	Long: `Re-generates a new alp config file (default location: /etc/alp/alp.yaml).
Since this file also contains a randomly generated default key, that will also be ge-generated.

To change only the key, rather directly edit said config file.
Furthemore, this prints the generated config to stdout.
The main purpose of printing is convenience: Every time you (re-) intialize alp, you will want
to update your password on the android side as well!

If using the default config file location (recommended), this command needs to be executed as root!

Warning: This will overwrite the existing alp config file (if it exists).`,
	Run: func(_ *cobra.Command, _ []string) {
		// init
		rootArgs := ini.Init()
		err := viper.Unmarshal(&initArgs)
		if err != nil {
			log.Fatal(err)
		}

		// 
		// ALP Config file
		//
		// delete old config
		err = os.Remove(rootArgs.Config)
		if err != nil {
			log.Warn(err)
		}
		// prepare new config
		templateVariables := map[string]interface{}{
			"Key": random.RandSeq(32),
			"Targets": initArgs.Target,
		}
		log.Tracef("%v", templateVariables)
		t, err := template.New("defaultConfigFileTemplate").Parse(defaultConfigFileAlpTemplate)
		if err != nil {
			log.Fatal(err)
		}
		buf := &bytes.Buffer{}
		if err := t.Execute(buf, templateVariables); err != nil {
			log.Fatal(err)
		}
		defaultConfigFileContent := buf.String()
		// write new config
		err = myfilepath.CreateFileWithPath(rootArgs.Config, defaultConfigFileContent, 0660)
		if err != nil {
			log.Warnf("Hint: You may need to run this command as root or with sudo!")
			log.Fatal(err)
		}
		log.Infof("created the file (%s): \n%s", rootArgs.Config, defaultConfigFileContent)

		// 
		// PAM Config file(s)
		//
		log.Info("attempting to patch pam files")
		patched := false
		for _, configFile := range initArgs.PamConfigFile {
			log.Infof("attempting to patch pam file %s", configFile)
			if fileExists(configFile) {
				if patchFile(configFile) {
					patched = true
				}
			} else {
				log.Tracef("File not found: %s", configFile)
			}
		}
		
		if !patched {
			log.Warnf("Did patch any of the files %s. This could be because they are already patched. Otherwise, the output above may provide more info!", initArgs.PamConfigFile)
		}
		
	},
}

func init() {
	rootCmd.AddCommand(initCmd)

	// Here you will define your flags and configuration settings.

	// Cobra supports Persistent Flags which will work for this command
	// and all subcommands, e.g.:
	// initCmd.PersistentFlags().String("foo", "", "A help for foo")

	// Cobra supports local flags which will only run when this command
	// is called directly, e.g.:
	initCmd.Flags().StringSliceP("target", "t", []string{fmt.Sprintf("%s:7654", defaultGatewayConst)},
		fmt.Sprintf(`Target device: <IP>|<Host>:<Port> of android device.
Example: 10.0.0.3:7654.
Recommendations: Stick to the default port as used in the example.
In your router config, reserve the IP address for your android device.

If you use your anroid phone as a hotspot you can stick to the default config
and simply omit this param.
That is because the fixed string %s will be replaced by your actual default gateway.
`, defaultGatewayConst))
	initCmd.Flags().StringSliceP("pamConfigFile", "p", []string{"/etc/authselect/system-auth", "/etc/pam.d/common-auth"},
		fmt.Sprintf(`Pam Config file to patch.
If the specified path does not exist, it will be ignored, but a warning will be logged.
The warning will however only be logged if none of the specified files can be patched.
Specify /dev/null to explicitly not perform auto-patching.
In this case you need to insert the pam config yourself to activate alp in pam.
The pam config line that is expected in either case is the following line:
%s

Auto-patching will insert the line before the first auth line, and if there are comment lines present it will be placed before them.
Furthermore, a backup will be created for each auto-patched file in its original location, but with the suffix '.backup-before-alp-init'.
`, defaultConfigPam))
	viper.BindPFlags(initCmd.Flags())
}

const (
	defaultConfigFileAlpTemplate = `---
key: {{ .Key }}
targets:
{{- range $target := .Targets }}
  - {{ $target }}
{{- end }}
`
	defaultConfigPam = "auth    sufficient      pam_exec.so stdout /usr/sbin/alp auth"
	BackupSuffix   = ".backup-before-alp-init"
)

func fileExists(filePath string) bool {
	_, err := os.Stat(filePath)
	return err == nil
}

func patchFile(filePath string) bool {
	file, err := os.Open(filePath)
	if err != nil {
		log.Printf("Error opening file: %s", err)
		return false
	}
	defer file.Close()

	lines := make([]string, 0)
	inserted := false

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := scanner.Text()

		if strings.TrimSpace(line) == defaultConfigPam {
			// Skip inserting the line if it already exists
			return false
		}

		if !inserted && strings.TrimSpace(line) == "" {
			lines = append(lines, defaultConfigPam)
			inserted = true
		}

		lines = append(lines, line)
	}

	if err := scanner.Err(); err != nil {
		log.Printf("Error scanning file: %s", err)
		return false
	}

	if !inserted {
		lines = append([]string{defaultConfigPam}, lines...)
	}

	backupPath := filePath + BackupSuffix
	if err := createBackup(filePath, backupPath); err != nil {
		log.Printf("Error creating backup: %s", err)
		return false
	}

	if err := os.WriteFile(filePath, []byte(strings.Join(lines, "\n")), 0644); err != nil {
		log.Printf("Error writing patched file: %s", err)
		return false
	}
	log.Infof("Patched %s and created backup %s", filePath, backupPath)

	return true
}

func createBackup(srcPath, destPath string) error {
	srcFile, err := os.Open(srcPath)
	if err != nil {
		return err
	}
	defer srcFile.Close()

	destFile, err := os.Create(destPath)
	if err != nil {
		return err
	}
	defer destFile.Close()

	_, err = srcFile.Seek(0, 0)
	if err != nil {
		return err
	}

	_, err = io.Copy(destFile, srcFile)
	if err != nil {
		return err
	}

	return nil
}
