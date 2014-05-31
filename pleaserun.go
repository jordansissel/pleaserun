package main

import (
	"github.com/Sirupsen/logrus"
	"github.com/jessevdk/go-flags"
	"os"
	"pleaserun"
)

var log = logrus.New()

type Options struct {
	Name        string               `long:"name" description:"The name of this program"`
	Credential  pleaserun.Credential `long:"credential" description:"The credentials to run this program with; user[:group]"`
	Description string               `long:"description" description:"The human-readable description of your program"`
	PreStart    string               `long:"prestart" description:"A command to execute before starting and restarting. A failure of this command will cause the start/restart to abort. This is useful for health checks, config tests, or similar operations."`
}

func init() {
	log.Formatter = new(logrus.TextFormatter)
	pleaserun.Log = log
}

func main() {
	//log := log.WithFields(logrus.Fields{"hello": "world"})
	var options Options
	parser := flags.NewParser(&options, flags.Default)
	if _, err := parser.Parse(); err != nil {
		log.Error(err)
		os.Exit(1)
	}
	f := pleaserun.NewProgram()
	log.Info(f)
	log.Info(options.Name)
	log.Info(options.Credential)
}
