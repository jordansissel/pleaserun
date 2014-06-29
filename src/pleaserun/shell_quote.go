package pleaserun

import (
  "fmt"
  "strings"
  "bytes"
)

func shell_quote(input string) (string, error) {
  input = strings.Replace(input, `\`, `\\`, -1)
  input = strings.Replace(input, `"`, `\"`, -1)
  return fmt.Sprintf(`"%s"`, input), nil
}

func shell_args_escape(input []string) (string, error) {
  var buf bytes.Buffer
  for _, arg := range input {
    s, _ := shell_quote(arg)
    buf.Write([]byte(s))
    buf.Write([]byte(" "))
  }
  return shell_quote(buf.String())
}
