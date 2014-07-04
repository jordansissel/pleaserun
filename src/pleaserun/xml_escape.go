package pleaserun

import (
	"bytes"
	"encoding/xml"
)

func xml_escape(input string) (string, error) {
	buf := bytes.Buffer{}
	err := xml.EscapeText(&buf, []byte(input))
	if err != nil {
		return "", err
	}
	return buf.String(), nil
}
