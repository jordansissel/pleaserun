package pleaserun

import (
	"errors"
	"fmt"
	"strings"
)

type Credential struct {
	User  string
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
} // *Credential#UnmarshalFlag

func (c Credential) String() string {
	return fmt.Sprintf("%s:%s", c.User, c.Group)
} // Credential#String
