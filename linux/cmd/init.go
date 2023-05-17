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
	"bytes"
	"html/template"
	"os"

	"github.com/gernotfeichter/alp/lib"
	log "github.com/sirupsen/logrus"
	"github.com/spf13/cobra"
	"github.com/spf13/viper"
)

type InitArgs struct {
	Targets  []string
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
	Run: func(cmd *cobra.Command, args []string) {
		// init
		rootArgs := lib.Init()
		err := viper.Unmarshal(&initArgs)
		if err != nil {
			log.Fatal(err)
		}
		// delete old config
		err = os.Remove(rootArgs.Config)
		if err != nil {
			log.Warn(err)
		}
		// prepare new config
		templateVariables := map[string]interface{}{
			"Key": lib.RandSeq(32),
			"Targets": initArgs.Targets,
		}
		log.Tracef("%d", templateVariables)
		t, err := template.New("defaultConfigFileTemplate").Parse(defaultConfigFileTemplate)
		if err != nil {
			log.Fatal(err)
		}
		buf := &bytes.Buffer{}
		if err := t.Execute(buf, templateVariables); err != nil {
			log.Fatal(err)
		}
		defaultConfigFileContent := buf.String()
		// write new config
		err = lib.CreateFileWithPath(rootArgs.Config, defaultConfigFileContent, 0660)
		if err != nil {
			log.Warnf("Hint: You may need to run this command as root or with sudo!")
			log.Fatal(err)
		}
		log.Infof("created the file (%s): \n%s", rootArgs.Config, defaultConfigFileContent)
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
	initCmd.Flags().StringSliceP("targets", "t", []string{}, "Target device: <IP>|<Host>:<Port> of android device. Example: 10.0.0.3:7654. Recommendations: Stick to the default port as used in the example. In your router config, reserve the IP address for your android device.")

	viper.BindPFlags(initCmd.Flags())
}

const defaultConfigFileTemplate string = `---
key: {{ .Key }}
targets:
{{- range $target := .Targets }}
  - {{ $target }}
{{- end }}
`