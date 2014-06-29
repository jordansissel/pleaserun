package pleaserun

import ()

type Program struct {
	Name        string `long:"name" description:"The name of this program"`
  Description string `long:"description" description:"The human-readable description of your program"`
  Author      string `long:"author"`

	Program string
	Args    []string

	//Environment Environment
	PreStart    string               `long:"prestart" description:"A command to execute before starting and restarting. A failure of this command will cause the start/restart to abort. This is useful for health checks, config tests, or similar operations."`

  Chdir string `long:"chdir" description:"The directory to chdir to before running this program"`
  Chroot string `long:"chroot" description:"The directory to chroot to before running this program"`
  Nice uint8 `long:"nice" description:"The nice level to add to this program before running"`
  Credential  Credential `long:"credential" description:"The credentials to run this program with. Syntax is: 'user' or 'user:group'"`
}

func (p *Program) Defaults() {
  if len(p.Description) == 0 {
    p.Description = "no description given"
  }
  if len(p.Chroot) == 0 {
    p.Chroot = "/"
  }
  if len(p.Chdir) == 0 {
    p.Chdir = "/"
  }
}
