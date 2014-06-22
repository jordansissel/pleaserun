package pleaserun

import (
  "os"
  "text/template"
	"github.com/Sirupsen/logrus"
  "bytes"
)

type File struct {
	Path     string      // The path on the filesystem where the file should be written
	Mode     os.FileMode // The file mode for this file
	Content  []byte // The file content
  // Owner? Group? Other?
}

func Files(program Program, platform Platform) ([]File, error) {
  files := make([]File, 0)
  for path, pf := range platform.Files {
    log := log.WithFields(logrus.Fields{"template": pf.Template})
    outfile := File{}
    outfile.Mode = pf.Mode
    outfile.Path = path
    outbuf := bytes.Buffer{}

    fd, err := os.Open(pf.Template)
    if err != nil {
      log.Errorf("Failed to open template (cause: %s)", err)
      return nil, err
    }

    var buf [16384]byte
    n, err := fd.Read(buf[:])
    if err != nil {
      log.Errorf("Failed to read template (cause: %s)", err)
      return nil, err
    }

    t, err := template.New("").Parse(string(buf[:n]))
    //t, err := template.ParseFiles(pf.Template)
    if err != nil {
      log.Errorf("Failed to parse template (cause: %s)", err)
      return nil, err
    }
    err = t.Execute(&outbuf, program)
    if err != nil {
      log.Errorf("Failed executing template (cause: %s)", err)
      return nil, err
    }
    outfile.Content = outbuf.Bytes()

    files = append(files, outfile)
  } /* for f := range platform.Files */

  return files, nil
} /* Files */
