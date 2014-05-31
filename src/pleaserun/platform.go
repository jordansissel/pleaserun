package pleaserun

import (
  "errors"
)

type Platform interface {
  Name() string
  Version() string

  Files(program Program) map[string][]byte
  Activation(program Program) []string
}

type PlatformInfo struct {
  Name string
  Version string
}

type PlatformCreator func(string, string) Platform

var PLATFORMS map[string]PlatformCreator = make(map[string]PlatformCreator)

func registerPlatform(name string, version string, creator PlatformCreator) {
  PLATFORMS[name] = creator
}

func NewPlatform(name string, version string) (p Platform, err error) {
  creator, ok := PLATFORMS[name]
  if !ok {
    return nil, errors.New("Unknown thing")
  }

  return creator(name, version), nil
}

// pleaserun.Files(sysv, myprogram)
// Each file from platform.Files(program), apply templating.
func Files(platform Platform, program Program) { }
// pleaserun.ActivationInstructions(sysv, myprogram)
// Each command from platform.ActivationInstructions(program) , apply templating.
func ActivationInstructions(platform Platform, program Program) { }
