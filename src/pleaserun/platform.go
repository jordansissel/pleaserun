package pleaserun

import (
	"encoding/json"
	"fmt"
	"github.com/Sirupsen/logrus"
	"os"
	"path/filepath"
)

type Platform struct {
	Files          map[string]FileTemplate `json:"files"`
	InstallActions [][]string              `json:"install_action"`
} /* type Platform */

func DefaultSearchPath() string {
	return filepath.Join(filepath.Dir(os.Args[0]), "templates")
} /* DefaultSearchPath */

func Search(name string, search_paths []string) (platform *Platform, err error) {
	for _, sp := range search_paths {
		path := filepath.Join(sp, name, "platform.json")
		platform, err = loadPlatformJSON(name, path)
		if platform != nil {
			return
		}
	}

	return nil, fmt.Errorf("Platform not found (cause: %s).", err)
} /* Search */

func loadPlatformJSON(name string, path string) (platform *Platform, err error) {
	log := log.WithFields(logrus.Fields{"search": path})
	log.Debug("Looking for platform.json")
	stat, err := os.Stat(path)
	if err != nil {
		return nil, fmt.Errorf("platform.json not found (cause: %s)", err)
	}
	if stat.IsDir() {
		return nil, fmt.Errorf("platform.json is a directory, but I expected a file.")
	}

	var buf [16384]byte

	if stat.Size() > int64(cap(buf)) {
		return nil, fmt.Errorf("platform.json is too large (%d bytes)", stat.Size())
	}

	file, err := os.Open(path)
	if err != nil {
		return nil, fmt.Errorf("failed to open platform.json (cause: %s)", err)
	}

	n, err := file.Read(buf[:])
	if err != nil {
		return nil, fmt.Errorf("failed reading from platform.json (cause: %s)", err)
	}

	platform = &Platform{}
	err = json.Unmarshal(buf[:n], platform)
	if err != nil {
		return nil, fmt.Errorf("failed parsing json from platform.json (cause: %s)", err)
	}

	// Prefix all file template paths with the root where this platform.json is located
	// For "/path/to/platform.json", "init.sh" becomes "/path/to/init.sh"
	root := filepath.Dir(path)
	for name, file := range platform.Files {
		file.Template = filepath.Join(root, file.Template)
		// Overwrite because 'range' gives us a copy of the TemplateFile
		platform.Files[name] = file
	}
	return platform, nil
} /* loadPlatformJSON */
