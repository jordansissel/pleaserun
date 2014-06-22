package pleaserun

import (
	"os"
)

type FileTemplate struct {
	Mode     os.FileMode // The file mode for this file
	Template string      // The template file to use to generate the content
}
