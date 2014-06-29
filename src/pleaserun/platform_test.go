package pleaserun

import (
  "testing"
)

func TestLoading(t *testing.T) {
  testLoading(t, "launchd", 1, 1)
  testLoading(t, "upstart-1.12", 1, 0)
}
func testLoading(t *testing.T, search string, files int, install_actions int) {
  /* Note: Hardcoded assumption that launchd is a valid platform */
  paths := []string{DefaultSearchPath()}
  platform, err := Search(search, paths)
  if err != nil {
    t.Errorf("Failed loading %s platform in %v (cause: %s)", search, paths, err)
    return
  }
  if len(platform.Files) != files {
    t.Errorf("%s: Expected at %d files, got %d", search, files, len(platform.Files))
    return
  }
  if len(platform.InstallActions) != install_actions {
    t.Errorf("%s: Expected at %d install actions, got %d", search, install_actions, len(platform.InstallActions))
    return
  }
  
	program := Program{}
	program.Name = "example"
	program.Program = "sleep"
	program.Args = []string{"30"}
  _, err = Files(program, *platform)
  if err != nil {
    t.Errorf("Failed to generate files: %s", err)
    return
  }
} /* testLoading */

func TestLoadingFailure(t *testing.T) {
  if _, err := Search("whatever", []string{"/some/missing/directory"}); err == nil {
    t.Errorf("Expected error while trying to load a non existant platform")
    return
  }
} /* TestLoadingFailure */
