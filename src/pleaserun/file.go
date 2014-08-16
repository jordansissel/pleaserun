package pleaserun

import (
	"os"
)

type FileTemplate struct {
	Mode     os.FileMode `json:"mode,string"` // The file mode for this file
	Template string      `json:"template"`    // The template file to use to generate the content
}
