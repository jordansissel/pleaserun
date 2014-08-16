package pleaserun

import ()

type Program struct {
	Name        string `json:"name,omitempty" long:"name" description:"The name of this program"`
	Description string `json:"description,omitempty" long:"description" description:"The human-readable description of your program"`
	Author      string `json:"author,omitempty" long:"author"`

	Program string   `json:"program"`
	Args    []string `json:"args,omitempty"`

	//Environment Environment
	PreStart string `json:"prestart,omitempty" long:"prestart" description:"A command to execute before starting and restarting. A failure of this command will cause the start/restart to abort. This is useful for health checks, config tests, or similar operations."`

	Chdir      string     `json:"chdir,omitempty" long:"chdir" description:"The directory to chdir to before running this program"`
	Chroot     string     `json:"chroot,omitempty" long:"chroot" description:"The directory to chroot to before running this program"`
	Nice       uint8      `json:"nice" long:"nice" description:"The nice level to add to this program before running"`
	Credential Credential `json:"credential,omitempty" long:"credential" description:"The credentials to run this program with. Flag syntax is: 'user' or 'user:group'"`
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
