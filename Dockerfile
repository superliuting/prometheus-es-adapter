# Build Stage
FROM golang:alpine AS build-stage

LABEL app="build-prometheus-es-adapter"
LABEL REPO="https://github.com/pwillie/prometheus-es-adapter"

ENV GOROOT=/usr/local/go \
    GOPATH=/gopath \
    GOBIN=/gopath/bin \
    PROJPATH=/gopath/src/github.com/pwillie/prometheus-es-adapter

RUN apk add -U --no-progress build-base git

ADD . /gopath/src/github.com/pwillie/prometheus-es-adapter
WORKDIR /gopath/src/github.com/pwillie/prometheus-es-adapter

RUN make build-alpine

# Final Stage
FROM alpine:latest

ARG GIT_COMMIT
ARG VERSION
LABEL REPO="https://github.com/pwillie/prometheus-es-adapter"
LABEL GIT_COMMIT=$GIT_COMMIT
LABEL VERSION=$VERSION

# Because of https://github.com/docker/docker/issues/14914
ENV PATH=$PATH:/opt/prometheus-es-adapter/bin

WORKDIR /opt/prometheus-es-adapter/bin

COPY --from=build-stage /gopath/src/github.com/pwillie/prometheus-es-adapter/bin/prometheus-es-adapter /opt/prometheus-es-adapter/bin/
RUN chmod +x /opt/prometheus-es-adapter/bin/prometheus-es-adapter

CMD /opt/prometheus-es-adapter/bin/prometheus-es-adapter