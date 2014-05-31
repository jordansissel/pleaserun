package pleaserun

import (
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

func NewProgram() (p Program) {
	p.Credential = Credential{User: "root"}
	return
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
