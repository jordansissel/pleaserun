package main

import (
	"github.com/Sirupsen/logrus"
	"github.com/jessevdk/go-flags"
	"os"
	"path"
	"pleaserun"
)

var log = logrus.New()

type Settings struct {
	Name        string `long:"name" description:"The name of this program"`
	Description string `long:"description" description:"The human-readable description of your program"`
	Debug       bool   `long:"debug" description:"Debug-level logging"`

	//Credential  pleaserun.Credential `long:"credential" description:"The credentials to run this program with; user[:group]"`
	//PreStart    string               `long:"prestart" description:"A command to execute before starting and restarting. A failure of this command will cause the start/restart to abort. This is useful for health checks, config tests, or similar operations."`
}

func init() {
	log.Formatter = new(logrus.TextFormatter)
	pleaserun.SetLogger(log)
}

func main() {
	//log := log.WithFields(logrus.Fields{"hello": "world"})
	var settings Settings
	parser := flags.NewParser(&settings, flags.Default|flags.PassAfterNonOption)
	params, err := parser.Parse()
	if err != nil {
		log.Error(err)
		os.Exit(1)
	}

	if settings.Debug {
		log.Level = logrus.Debug
	}

	if len(params) == 0 {
		log.Error("Missing program to run!")
		os.Exit(1)
	}

	if len(settings.Name) == 0 {
		_, settings.Name = path.Split(params[0])
		log := log.WithFields(logrus.Fields{"default": settings.Name})
		log.Info("No program name given, picking a default.")
	}
	program := pleaserun.Program{}
	program.Name = settings.Name
	program.Program = params[0]
	program.Args = params[1:]

	search_path := []string{pleaserun.DefaultSearchPath()}
	platform, err := pleaserun.Search("launchd", search_path)
	if err != nil {
		log := log.WithFields(logrus.Fields{"cause": err})
		log.Fatal("Failed to load platform")
	}

	files, err := pleaserun.Files(program, *platform)
	if err != nil {
		log := log.WithFields(logrus.Fields{"cause": err})
		log.Fatal("Failed to generate files")
	}

	for _, f := range files {
		os.Stdout.Write(f.Content)
	}
}
