package pleaserun

import (
  "testing"
  "github.com/Sirupsen/logrus"
)

func TestLoadingLaunchd(t *testing.T) {
  log.Level = logrus.Debug
  /* Note: Hardcoded assumption that launchd is a valid platform */
  paths := []string{DefaultSearchPath()}
  platform, err := Search("launchd", paths)
  if err != nil {
    t.Errorf("Failed loading launchd platform in %v (cause: %s)", paths, err)
    return
  }
  if len(platform.Files) == 0 {
    t.Errorf("Expected at least one file")
    return
  }
  if len(platform.InstallActions) == 0 {
    t.Errorf("Expected at least one install action")
    return
  }
}

func TestLoadingFailure(t *testing.T) {
  if _, err := Search("whatever", []string{"/some/missing/directory"}); err == nil {
    t.Errorf("Expected error while trying to load a non existant platform")
    return
  }
}
