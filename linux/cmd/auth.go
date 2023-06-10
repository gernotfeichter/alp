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
	"context"
	"encoding/json"
	"fmt"
	"os"
	"time"

	"github.com/gernotfeichter/alp/api"
	"github.com/gernotfeichter/alp/crypt"
	"github.com/gernotfeichter/alp/ini"

	//"github.com/gosuri/uilive"
	log "github.com/sirupsen/logrus"
	"github.com/spf13/cobra"
	"github.com/spf13/viper"
)

type AuthArgs struct {
	Timeout time.Duration
	RefreshInterval time.Duration
	Level string
	MockSuccess bool
	Targets []string
	Key string
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
	Run: func(_ *cobra.Command, _ []string) {
		// init
		ini.Init()
		log.Tracef("starting alp auth")
		var authArgs AuthArgs
		viper.Unmarshal(&authArgs)
		if authArgs.MockSuccess {
			log.Warn("mockSuccess is true! This should only be used in testing and not on a real system!")
			os.Exit(0)
		}

		// perform rest request to android
		authRequest(authArgs)

		// console output while time is ticking
		// deadline := time.Now().Add(authArgs.Timeout)
		// ticker := time.NewTicker(authArgs.RefreshInterval)
		// done := make(chan bool)
		// writer := uilive.New()
		// log.SetOutput(writer)
		// writer.Start()
		// go func() {
		// 	for {
		// 		select {
		// 		case <-done:
		// 			return
		// 		case t := <-ticker.C:
		// 			timeLeft := deadline.Sub(t)
		// 			log.Infof("awaiting approval from android: %.0fs left", timeLeft.Seconds())
		// 		}
		// 	}
		// }()
		// time.Sleep(authArgs.RefreshInterval)
		// ticker.Stop()
		// done <- true
		// log.Println("Ticker stopped")
	},
}

func init() {
	rootCmd.AddCommand(authCmd)

	// Here you will define your flags and configuration settings.
	// Cobra also supports local flags, which will only run
	// when this action is called directly.
	authCmd.Flags().DurationP("timeout", "t", time.Second * 60,
	"wait for as long till the authentication is given up and fallback to the next pam module in /etc/pam.d/common-auth will occur")
    authCmd.Flags().BoolP("mockSuccess", "s", false, `Warning: Never ever use true in a real setup!
	Setting this to true hardcodes authentication success and should only be used in testing!`)
	authCmd.Flags().DurationP("refreshInterval", "r", time.Second * 1, 
		"refreshes the 'waiting for android user input (x seconds left)' text by the given interval")
	authCmd.Flags().StringP("key", "k", "", "key aka password used by both linux (client) and android (server) for communcation. utf-8 string. " +
		"Recommendation: do not override this param. Use the alp init command instead, which writes the key to /etc/alp/alp.yaml and " +
		"takes precedence over the empty default specified for this command line arg.")

	viper.BindPFlags(authCmd.Flags())
}

func authRequest(authArgs AuthArgs) {
	for _, target := range authArgs.Targets {
		client, err := api.NewClient(fmt.Sprintf("http://%s", target))
		if err != nil {
			log.Fatalf("Could not create rest client: %s", err)
		}
		requestExpirationTime := time.Now().Add(authArgs.Timeout)
		requestExpirationTimeString := requestExpirationTime.Format(time.RFC3339)
		ctx, cancel := context.WithDeadline(context.Background(), requestExpirationTime)
		defer cancel()
		if err != nil {
			log.Fatal(err)
		}
		hostname, _ := os.Hostname()
		encryptedMessage := crypt.AesGcmPbkdf2EncryptToBase64(
			authArgs.Key,
			fmt.Sprintf(`{"host":"%s","requestExpirationTime":"%s"}`, hostname, requestExpirationTimeString))
		if err != nil {
			log.Fatalf("Error encrypting message: %s", err)
		}
		log.Info("sending auth request to connected device")
		res, err := client.GetAuthenticationStatus(ctx, &api.AuthRequest{
			EncryptedMessage: api.EncryptedMessage(encryptedMessage),
		})
		if err != nil {
			log.Fatal(err)
		}
		switch r := res.(type) {
		case *api.AuthResponse:
			log.Tracef("200 - Success authorized=%s. Note that checking the auth flag is still pending before being fully authorized.", r)
			decryptedMessage := crypt.AesGcmPbkdf2DecryptFromBase64(authArgs.Key, string(r.EncryptedMessage))
			var responseJson map[string]any
			err := json.Unmarshal([]byte(decryptedMessage), &responseJson)
			if err != nil {
				log.Fatalf("Parsing response as json failed: %s", err)
			}
			if !responseJson["auth"].(bool) {
				log.Fatalf("not authorized!")
			}
			log.Info("authorized!")
			os.Exit(0)
		case *api.GetAuthenticationStatusBadRequest:
			log.Fatalf("400 - BadRequest: %s", res)
		case *api.GetAuthenticationStatusUnauthorized:
			log.Fatalf("401 - Unauthorized: %s", res)
		}
		log.Fatal("Could not classify response into known cases.")
	}
	log.Fatal("No targets delivered a meaningful response.")
}