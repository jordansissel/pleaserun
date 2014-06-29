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

var template_funcs template.FuncMap = template.FuncMap{
  "xml_escape": xml_escape,
  "shell_quote": shell_quote,
  "shell_args_escape": shell_args_escape,
}

func Files(program Program, platform Platform) ([]File, error) {
  files := make([]File, 0)
  for path, pf := range platform.Files {
    log := log.WithFields(logrus.Fields{"template": pf.Template})
    outfile := File{}
    outfile.Mode = pf.Mode
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

    t, err := template.New(pf.Template).Funcs(template_funcs).Parse(string(buf[:n]))
    if err != nil {
      log.Errorf("Failed to parse template (cause: %s)", err)
      return nil, err
    }
    err = t.Execute(&outbuf, program)
    if err != nil {
      log.Errorf("Failed executing content template (cause: %s)", err)
      return nil, err
    }
    outfile.Content = outbuf.Bytes()

    var pathname bytes.Buffer
    t, err = template.New("path-name").Parse(path)
    if err != nil {
      log.Errorf("Failed parsing path template %v (cause; %s)", path, err)
      return nil, err
    }
    err = t.Execute(&pathname, program)
    if err != nil {
      log.Errorf("Failed executing path name template (cause: %s)", err)
      return nil, err
    }
    outfile.Path = string(pathname.Bytes())

    files = append(files, outfile)
  } /* for f := range platform.Files */

  return files, nil
} /* Files */

