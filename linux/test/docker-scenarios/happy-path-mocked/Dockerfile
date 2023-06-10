# This Dockerfile is only used for testing

FROM golang:1.20

# Set destination for COPY
WORKDIR /ws

# Copy sources
COPY go.mod go.sum ./
COPY cmd cmd
COPY crypt crypt
COPY filepath filepath
COPY ini ini
COPY random random
COPY main.go .
# notice: the following is a hard linked file to ../android/lib/rest_api_server/openapi.yaml:
COPY openapi.yaml openapi.yaml

# Build
RUN go install -v github.com/ogen-go/ogen/cmd/ogen@latest
RUN go generate ./... && \
    go mod tidy
RUN go mod download
RUN CGO_ENABLED=0 GOOS=linux go build -o /usr/sbin/alp

# Test
RUN useradd test
COPY test/docker-scenarios/happy-path-mocked/alp.yaml /etc/alp/alp.yaml
COPY test/resources/common-auth /etc/pam.d/common-auth
USER test
# this is the main line to be tested here
RUN su root

# the following is only there to satisfy vscode/linting
CMD ["/alp"]
LABEL Name="testing"
LABEL Version="0.0.0"
EXPOSE 8080