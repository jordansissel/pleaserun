package pleaserun

import (
)

type Program struct {
	Name        string
	Description string
  Author      string

	Program     string
	Args        []string
	//Credential  Credential

	//Environment Environment
  Nice uint8
	PreStart    string
}
