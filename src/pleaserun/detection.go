package pleaserun

import (
	"fmt"
	"os"
	"runtime"
	"strings"
)

var osplatform map[string]string = map[string]string{
	"ubuntu-14.04": "upstart-1.12",
	"ubuntu-13.10": "upstart-1.12",
	"ubuntu-13.04": "upstart-1.12",
	"ubuntu-12.10": "upstart-1.12",
	"ubuntu-12.04": "upstart-1.12",
	"darwin":       "launchd",
}

func DetectOS() (string, error) {
	switch runtime.GOOS {
	case "darwin":
		return "darwin", nil
	//case "freebsd":
	//return detectPlatformFreeBSD()
	//case "solaris":
	//return detectPlatformSolaris()
	case "linux":
		return detectPlatformLinux()
	}
	return "", fmt.Errorf("Unable to detect your host platform and version")
}

func DetectPlatform(os string) (string, error) {
	platform, ok := osplatform[os]
	if !ok {
		return "", fmt.Errorf("Unable to determine correct run platform for os %s", os)
	}
	return platform, nil
}

func readFile(path string, buffer []byte) (int, error) {
	_, err := os.Stat("/etc/lsb-release")
	if err != nil {
		return 0, err
	}

	fd, err := os.Open("/etc/lsb-release")
	if err != nil {
		return 0, err
	}

	defer fd.Close()
	n, err := fd.Read(buffer)
	if err != nil {
		return 0, err
	}
	return n, nil
}

func detectPlatformLinux() (string, error) {
	var buf [16384]byte
	n, err := readFile("/etc/lsb-release", buf[:])
	if err != nil {
		return "", err
	}

	var platform string
	var version string

	text := string(buf[:n])
	for _, line := range strings.Split(text, "\n") {
		s := strings.Split(line, "=")
		switch s[0] {
		case "DISTRIB_ID":
			platform = strings.ToLower(s[1])
		case "DISTRIB_RELEASE":
			version = strings.ToLower(s[1])
		}
	}

	return fmt.Sprintf("%s-%s", platform, version), nil
} /* detectPlatformLinux */
