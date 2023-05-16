package lib

import (
	log "github.com/sirupsen/logrus"
	"github.com/spf13/viper"
)

type RootArgs struct {
	Config string
	Level  string
}

func Init() RootArgs {
	initLog()
	rootArgs := initRootArgs()
	initLogLevel(rootArgs)
	return rootArgs
}

func initLog() {
	log.SetFormatter(&log.TextFormatter{
	    ForceColors: true,
	    DisableTimestamp: true,
	})
}

func initRootArgs() RootArgs {
	// init
	var rootArgs RootArgs
	viper.Unmarshal(&rootArgs)
	log.Trace("Config=%s", rootArgs.Config)
	log.Trace("Level=%s", rootArgs.Level)
	return rootArgs
}

func initLogLevel(rootArgs RootArgs) {
	level, err := log.ParseLevel(rootArgs.Level)
	if err != nil {
		log.Fatal(err)
	}
	log.SetLevel(level)
	log.Trace("RootCmd initConfig finished.")
}