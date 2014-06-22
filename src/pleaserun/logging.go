package pleaserun

import (
	"github.com/Sirupsen/logrus"
)

var log = logrus.New()

func SetLogger(l *logrus.Logger) {
	log = l
}
