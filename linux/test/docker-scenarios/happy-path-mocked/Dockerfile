# syntax=docker/dockerfile:1
# This Dockerfile is only used for testing

FROM golang:1.20

# Set destination for COPY
WORKDIR /ws

# Download Go modules
COPY go.mod go.sum ./
RUN go mod download

# Copy sources
COPY cmd cmd
COPY main.go .

# Build
RUN CGO_ENABLED=0 GOOS=linux go build -o /alp
RUN chmod u+x /alp

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