package pleaserun

import (
  "testing"
)

func TestXMLEscape(t *testing.T) {
  text := "<hello>"
  escaped, err := xml_escape(text)
  if err != nil {
    t.Errorf("Failed to xml escape %v. Cause: %s", text, err)
    return
  }

  expected := "&lt;hello&gt;" 
  if escaped != expected {
    t.Errorf("Expected %v, got %v", expected, escaped, err)
    return
  }
}
