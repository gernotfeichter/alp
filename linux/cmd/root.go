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
	"fmt"
	log "github.com/sirupsen/logrus"
	"os"
	"time"

	"github.com/spf13/cobra"
	"github.com/spf13/viper"
)

var cfgFile string

type RootArgs struct {
	Timeout string
	RefreshInterval string
	Level string
}

var RootArgsParsed RootArgs

// rootCmd represents the base command when called without any subcommands
var rootCmd = &cobra.Command{
	Use:   "alp",
	Short: "alp - android-linux-pam",
	Long: `Alp is a convenient - yet secure - authentication method that lets you use your android device as a key for your linux machine.

To be able to use this, you will also need to use the android counterpart - See:

https://github.com/gernotfeichter/alp
`,
	Run: func(cmd *cobra.Command, args []string) {
		// init
		viper.Unmarshal(&RootArgsParsed)
		level, err := log.ParseLevel(RootArgsParsed.Level)
		if err != nil {
			log.Fatal(err)
		}
		log.SetLevel(level)
		tickerTimeout, err := time.ParseDuration(RootArgsParsed.Timeout)
		if err != nil {
			log.Fatalf("Cloud not parse %s as go duration!", RootArgsParsed.Timeout)
		}
		refreshInterval, err := time.ParseDuration(RootArgsParsed.RefreshInterval)
		if err != nil {
			log.Fatalf("Cloud not parse %s as go duration!", RootArgsParsed.RefreshInterval)
		}
		ticker := time.NewTicker(refreshInterval)
		done := make(chan bool)

		go func() {
			for {
				select {
				case <-done:
					return
				case t := <-ticker.C:
					log.Println("Tick at", t)
				}
			}
		}()

		time.Sleep(tickerTimeout)
		ticker.Stop()
		done <- true
		log.Println("Ticker stopped")
	},
}

// Execute adds all child commands to the root command and sets flags appropriately.
// This is called by main.main(). It only needs to happen once to the rootCmd.
func Execute() {
	err := rootCmd.Execute()
	if err != nil {
		os.Exit(1)
	}
}

func init() {
	cobra.OnInitialize(initConfig)

	// Here you will define your flags and configuration settings.
	// Cobra supports persistent flags, which, if defined here,
	// will be global for your application.

	rootCmd.PersistentFlags().StringVar(&cfgFile, "config", "", "config file (default is /etc/alp/alp.yaml)")

	// Cobra also supports local flags, which will only run
	// when this action is called directly.
	rootCmd.Flags().DurationP("timeout", "t", time.Second * 15, 
		"wait for as long till the authentication is given up and fallback to the next pam module in /etc/pam.d/common-auth will occur")
	rootCmd.Flags().DurationP("refreshInterval", "r", time.Second * 1, 
		"refreshes the 'waiting for android user input (x seconds left)' text by the given interval")
	rootCmd.Flags().StringP("level", "l", "info", "Log Level (panic|fatal|error|warn|info|debug|trace)")

	viper.BindPFlags(rootCmd.Flags())
}

// initConfig reads in config file and ENV variables if set.
func initConfig() {
	if cfgFile != "" {
		// Use config file from the flag.
		viper.SetConfigFile(cfgFile)
	} else {
		viper.AddConfigPath("/etc/alp")
		viper.SetConfigName("alp")
		viper.SetConfigType("yaml")
	}

	viper.AutomaticEnv() // read in environment variables that match

	// If a config file is found, read it in.
	if err := viper.ReadInConfig(); err == nil {
		fmt.Fprintln(os.Stderr, "Using config file:", viper.ConfigFileUsed())
	}
}
