package pleaserun

import (
  "strings"
  "errors"
  "fmt"
)

type Program struct {
	Name        string
	Program     string
	Args        []string
	Description string
	Credential  Credential
	Environment Environment
	PreStart    string
}

func NewProgram() Program {
  return Program{Credential: Credential{User: "root", Group: "root"}}
}

type Credential struct {
	User string
	Group string
}

func (c *Credential) UnmarshalFlag(value string) error {
  if value == "" {
    return errors.New("Expected `user:group` or just `user`")
  }

  parts := strings.Split(value, ":")
  if len(parts) > 2 || len(parts) == 0 {
    return errors.New("Expected `user:group` or just `user`")
  }

  c.User = parts[0]

  if len(parts) == 2 {
    c.Group = parts[1]
  }

  return nil
} // Credential#UnmarshalFlag

func (c Credential) String() string {
  return fmt.Sprintf("%s:%s", c.User, c.Group)
}

type Environment interface {
	Variables() map[string]string
	WorkingDirectory() string
} // Environment

type PosixEnvironment struct {
	Umask  int
	Chroot string
	Nice   int
} // PosixEnvironment

type WindowsEnvironment struct {
} // WindowsEnvironment
