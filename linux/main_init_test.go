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
package main

import (
	"fmt"
	"os/exec"
	"testing"
	"time"
	mycmd "github.com/gernotfeichter/alp/cmd"

	"github.com/magiconair/properties/assert"
	log "github.com/sirupsen/logrus"
)

// test the alp init command
func Test_main_init(t *testing.T) {
	// given
	filePath := fmt.Sprintf("/tmp/common-auth-pathed-%s", time.Now())
	cmd := exec.Command("cp", "test/resources/common-auth-before-patch", filePath)
	cmd.Output()

	// when
	// we patch twice in a row to check idempotence
	output, err := runInitCmd(filePath)
	if err != nil {
		log.Fatalf("Could not run init command: %s %s", output, err)
	}
	output, err = runInitCmd(filePath)
	if err != nil {
		log.Fatalf("Could not run init command: %s %s", output, err)
	}
	
	// then
	// check backup file
	backupFile := filePath + mycmd.BackupSuffix
	cmd = exec.Command("diff", "test/resources/common-auth-before-patch", backupFile)
	output, err = cmd.Output()
	if err != nil {
		log.Infof("Diff output: %s", output)
		log.Fatalf("Error dffing file test/resources/common-auth-before-patch with %s: %s", backupFile, err)
	}
	assert.Equal(t, string(output), "")

	// check patched file
	cmd = exec.Command("diff", "test/resources/common-auth", filePath)
	output, err = cmd.Output()
	if err != nil {
		log.Fatalf("Diff is %s for filePath %s", output, filePath)
	}
	assert.Equal(t, string(output), "")
}

func runInitCmd(filePath string) ([]byte, error) {
	cmd := exec.Command("go", "run", "main.go", "init", "-p", filePath)
	output, err := cmd.Output()
	if err != nil {
		log.Fatalf("alp init failed %s", err)
	}
	log.Println(string(output))
	return output, err
}
