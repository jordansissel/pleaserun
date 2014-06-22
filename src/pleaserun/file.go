package pleaserun

import (
	"os"
)

type File struct {
	Path    string
	Mode    os.FileMode
	Content []byte
}
