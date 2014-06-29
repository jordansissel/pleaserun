

default: pleaserun

.PHONY: pleaserun
pleaserun:
	go build pleaserun.go

.PHONY: test
test:
	go test -c pleaserun
	./pleaserun.test


