package pleaserun

import (
  "path"
  "path/filepath"
  "text/template"
	"github.com/Sirupsen/logrus"
  "os"
  "bytes"
  "strings"
  //"io/ioutil"
)

type Builder struct {
  // The name of this platform (sysv, upstart, etc)
  Name string

  // The version of the platform this builder should target, if any.
  Version string

  SearchPath []string
}

func (b Builder) TemplateDirectory() string {
  return path.Join(b.Name, b.Version)
}

func (b Builder) Validate() (err error) {
  // Verify directory for this name/version can be found.
  return
}

func (b Builder) Files(program Program) ([]File, error) {
  dir := b.TemplateDirectory()
  log := log.WithFields(logrus.Fields{"path": dir})

  fi, err := os.Stat(dir)
  if err != nil {
    log := log.WithFields(logrus.Fields{"err": err})
    log.Error("Template path is not accessible")
    return nil, err
  }
  if !fi.IsDir() {
    log.Error("Template path must be a directory.")
    return nil, err
  }

  // Find all files in the template directory.
  files := make([]File, 0)
  err = filepath.Walk(dir, func(p string, fi os.FileInfo, err error) error {
    // Skip directories
    if fi.IsDir() {
      return err
    }
    log := log.WithFields(logrus.Fields{"path": p, "info": fi, "err": err})
    log.Info("walk")

    // TODO(sissel): Apply templating to the path name

    // Template the path name
    destination, err := templateString(strings.TrimPrefix(dir, p), program)
    if err != nil {
      return err
    }
    content, err := templateFile(p, program)
    if err != nil {
      return err
    }

    f := File{Path: destination, Mode: 0644, Content: []byte(content)}
    files = append(files, f)
    return err
  })

  return files, err
} /* Builder#Files */

func templateFile(path string, obj interface{}) (string, error) {
  t, err := template.ParseFiles(path)
  if err != nil {
    return "", err
  }
  return templateApply(t, obj)
}

func templateString(text string, obj interface{}) (string, error) {
  t := template.New("pleaserun")
  t, err := t.Parse(text)
  if err != nil {
    return "", err
  }
  return templateApply(t, obj)
}

func templateApply(t *template.Template, obj interface{}) (string, error) {
  var b bytes.Buffer
  err := t.Execute(&b, obj)
  if err != nil {
    return "", err
  }

  return b.String(), nil
}
