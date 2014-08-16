package main

import (
	"encoding/json"
	"github.com/Sirupsen/logrus"
	"github.com/jessevdk/go-flags"
	"os"
	"path"
	"pleaserun"
)

var log = logrus.New()

type Settings struct {
	pleaserun.Program

	Platform  string `long:"platform" description:"The platform to target, such as upstart-1.12. Optional. If not specified, pleaserun will attempt to detect the os and choose the best platform."`
	OS        string `long:"os" description:"The OS to target, such as ubuntu-14.04. Optional."`
	Debug     bool   `long:"debug" description:"Debug-level logging"`
	Overwrite bool   `long:"overwrite" description:"Overwrite any files"`
	JSON      bool   `long:"json" description:"Write file and install action data to stdout as JSON. When set, no files are written and no install actions are run. This is intended to be used with other tools."`
}

func init() {
	log.Formatter = new(logrus.TextFormatter)
	pleaserun.SetLogger(log)
}

func main() {
	var settings Settings
	settings.Program.Defaults()
	parser := flags.NewParser(&settings, flags.Default|flags.PassAfterNonOption)
	parser.Usage = "[OPTIONS] program [args ...]\n\nExample:\n  pleaserun --name ssh /usr/sbin/sshd -D"
	params, err := parser.Parse()
	if err != nil {
		os.Exit(1)
	}

	if settings.Debug {
		log.Level = logrus.Debug
	} else {
		log.Level = logrus.Warn
	}

	if len(params) == 0 {
		log.Error("No program to run. I need more information :)")
		parser.WriteHelp(os.Stdout)
		os.Exit(1)
	}

	if len(settings.Program.Name) == 0 {
		_, settings.Program.Name = path.Split(params[0])
		log := log.WithFields(logrus.Fields{"default": settings.Program.Name})
		log.Info("No program name given, picking a default.")
	}

	if len(settings.Platform) == 0 {
		log.Info("No platform given. Detecting platform.")
		os, err := pleaserun.DetectOS()
		if err != nil {
			log.Fatal("Cannot detect OS")
		}
		settings.Platform, err = pleaserun.DetectPlatform(os)
		log := log.WithFields(logrus.Fields{"platform": settings.Platform, "os": os})
		if err != nil {
			log.Fatal("Cannot detect platform and none was given, I don't know what to do.")
		}
	}

	program := settings.Program
	program.Program = params[0]
	program.Args = params[1:]

	search_path := []string{pleaserun.DefaultSearchPath(), "./platforms"}
	platform, err := pleaserun.FindPlatform(settings.Platform, search_path)
	if err != nil {
		log := log.WithFields(logrus.Fields{"cause": err, "platform": platform})
		log.Fatal("Failed to load platform")
	}

	files, err := pleaserun.Files(program, *platform)
	if err != nil {
		log := log.WithFields(logrus.Fields{"cause": err})
		log.Fatal("Failed to generate files")
	}

	runner := Runner{Files: files, InstallActions: platform.InstallActions}

	if settings.JSON {
		err = print(runner)
	} else {
		err = install(runner, settings.Overwrite)
	}
	if err != nil {
		log.Fatal(err)
	}
} // main

type Runner struct {
	Files          []pleaserun.File `json:"files"`
	InstallActions [][]string       `json:"install_actions"`
}

func print(runner Runner) (err error) {
	blob, err := json.Marshal(runner)
	if err != nil {
		return
	}
	os.Stdout.Write(blob)
	return
}

func install(runner Runner, overwrite bool) (err error) {
	for _, f := range runner.Files {
		log := log.WithFields(logrus.Fields{"path": f.Path})
		if _, err = os.Stat(f.Path); err == nil && !overwrite {
			log.Error("File already exists, aborting.")
			return
		}
		var fd *os.File
		if f.Mode == 0 {
			fd, err = os.Create(f.Path)
		} else {
			fd, err = os.OpenFile(f.Path, os.O_WRONLY|os.O_CREATE|os.O_TRUNC, f.Mode)
		}
		defer fd.Close()
		if err != nil {
			log := log.WithFields(logrus.Fields{"err": err})
			log.Error("Failed to open file")
			return
		}
		fd.Write(f.Content)
		log.Info("Wrote file")
	}
	return
}
