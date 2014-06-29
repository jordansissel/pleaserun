package pleaserun

import (
  "testing"
)

func TestShellQuote(t *testing.T) {
  tests := map[string]string{
    "hello world": `"hello world"`,
    "testing\"": `"testing\""`,
    "simple": `"simple"`,
  }

  for input, expected := range tests {
    output, _ := shell_quote(input)
    if output != expected {
      t.Errorf("Shell quoting failed.\nGot: %s\nExpected: %s", output, expected)
    }
  }
}
