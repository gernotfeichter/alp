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
	"context"
	"fmt"
	"io/fs"
	"os"
	"testing"

	log "github.com/sirupsen/logrus"
	"github.com/testcontainers/testcontainers-go"
)

func Test_main(t *testing.T) {
	dockerScenarioBaseDir := "test/docker-scenarios"
	dockerScenarios, err := os.ReadDir(dockerScenarioBaseDir)
	if err != nil {
		log.Fatal(err)
	}
	for _, dockerScenario := range dockerScenarios {
		log.Infof("Running test scenario: %s", dockerScenario.Name())
		runDockerScenario(dockerScenarioBaseDir, dockerScenario)
	}
}

func runDockerScenario(dockerScenarioBaseDir string, dockerScenario fs.DirEntry) {
	ctx := context.Background()
	df := testcontainers.FromDockerfile{
		Context:    ".",
		Dockerfile: fmt.Sprintf("%s/%s/Dockerfile", dockerScenarioBaseDir, dockerScenario.Name()),
		PrintBuildLog: true,
	}
	cr := testcontainers.ContainerRequest{
		FromDockerfile: df,
	}
	_, err := testcontainers.GenericContainer(ctx, testcontainers.GenericContainerRequest{
		ContainerRequest: cr,
		Started:          true,
		Logger:           log.StandardLogger(),
	})
	if err != nil {
		log.Fatal(err)
	}

}
