SOURCEDIR=.
SOURCES := $(shell find . -name '*.go')

BINARY=foo

.DEFAULT_GOAL: $(BINARY)

$(BINARY): $(SOURCES) build
	go build -o foo

.PHONY: build
build:
	glide update -v
	glide install

.PHONY: docker
docker:
	docker build -t fbgrecojr/gobuild:latest .

.PHONY: test
	go test $(go list ./... | grep -v /vendor/)

.PHONY: clean
clean:
	if [ -f ${BINARY} ] ; then rm ${BINARY} ; fi
