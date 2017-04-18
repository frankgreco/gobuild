# multi-stage build example

# build stage
ARG GO_VERSION=1.8.1
FROM golang:${GO_VERSION}-alpine AS build-stage
MAINTAINER fbgrecojr@me.com
WORKDIR /go/src/github.com/frankgreco/go-docker-build/
COPY ./ /go/src/github.com/frankgreco/go-docker-build/
RUN apk add --update --no-cache \
        wget \
        curl \
        git \
    && wget "https://github.com/Masterminds/glide/releases/download/v0.12.3/glide-v0.12.3-`go env GOHOSTOS`-`go env GOHOSTARCH`.tar.gz" -O /tmp/glide.tar.gz \
    && mkdir /tmp/glide \
    && tar --directory=/tmp/glide -xvf /tmp/glide.tar.gz \
    && export PATH=$PATH:/tmp/glide/`go env GOHOSTOS`-`go env GOHOSTARCH` \
    && glide update -v \
    && glide install \
    && CGO_ENABLED=0 GOOS=`go env GOHOSTOS` GOARCH=`go env GOHOSTARCH` go build -o foo \
    && go test $(go list ./... | grep -v /vendor/)

# production stage
FROM alpine:3.5
MAINTAINER fbgrecojr@me.com
COPY --from=build-stage /go/src/github.com/frankgreco/go-docker-build/foo .
ENTRYPOINT ["/foo"]