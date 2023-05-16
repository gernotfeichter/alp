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
	"os"
	"time"

	"github.com/gernotfeichter/alp/lib"
	"github.com/gernotfeichter/alp/api"
	log "github.com/sirupsen/logrus"

	"github.com/gosuri/uilive"
	"github.com/spf13/cobra"
	"github.com/spf13/viper"
)

type AuthArgs struct {
	Timeout string
	RefreshInterval string
	Level string
	MockSuccess bool
	Target  []string
}

// authCmd represents the auth command
var authCmd = &cobra.Command{
	Use:   "auth",
	Short: "alp - android-linux-pam",
	Long: `Alp is a convenient - yet secure - authentication method that lets you use your android device as a key for your linux machine.
	Run: func(cmd *cobra.Command, args []string) {


To be able to use this, you will also need to use the android counterpart - See:

https://github.com/gernotfeichter/alp
`,
	Run: func(cmd *cobra.Command, args []string) {
		// init
		lib.Init()
		log.Info("starting alp auth")
		var authArgs AuthArgs
		viper.Unmarshal(&authArgs)
		level, err := log.ParseLevel(authArgs.Level)
		if err != nil {
			log.Fatal(err)
		}
		log.SetLevel(level)
		timeout, err := time.ParseDuration(authArgs.Timeout)
		if err != nil {
			log.Fatalf("Cloud not parse %s as go duration!", authArgs.Timeout)
		}
		refreshInterval, err := time.ParseDuration(authArgs.RefreshInterval)
		if err != nil {
			log.Fatalf("Cloud not parse %s as go duration!", authArgs.RefreshInterval)
		}
		if authArgs.MockSuccess {
			log.Warn("mockSuccess is true! This should only be used in testing and not on a real system!")
			os.Exit(0)
		}

		now := time.Now()
		// perform rest request to android
		authRequest(authArgs)

		// fancy console output while time is ticking
		deadline := now.Add(timeout)
		ticker := time.NewTicker(refreshInterval)
		done := make(chan bool)
		writer := uilive.New()
		log.SetOutput(writer)
		writer.Start()
		go func() {
			for {
				select {
				case <-done:
					return
				case t := <-ticker.C:
					timeLeft := deadline.Sub(t)
					log.Infof("awaiting approval from android: %.0fs left", timeLeft.Seconds())
				}
			}
		}()
		time.Sleep(timeout)
		ticker.Stop()
		done <- true
		log.Println("Ticker stopped")
	},
}

func init() {
	rootCmd.AddCommand(authCmd)

	// Here you will define your flags and configuration settings.
	// Cobra also supports local flags, which will only run
	// when this action is called directly.
	authCmd.Flags().DurationP("timeout", "t", time.Second * 15, 
		"wait for as long till the authentication is given up and fallback to the next pam module in /etc/pam.d/common-auth will occur")
    authCmd.Flags().BoolP("mockSuccess", "s", false, `Warning: Never ever use true in a real setup!
	Setting this to true hardcodes authentication success and should only be used in testing!`)
	authCmd.Flags().DurationP("refreshInterval", "r", time.Second * 1, 
		"refreshes the 'waiting for android user input (x seconds left)' text by the given interval")

	viper.BindPFlags(authCmd.Flags())
}

func authRequest(authArgs AuthArgs) {
	for _, target := range authArgs.Target {
		_, err := api.NewClient(target)
		if err != nil {
			log.Fatal(err)
		}
		
	}
}