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
RUN apt-get update && apt-get install sudo && apt-get clean
ENV ROOT_PASSWORD="root-password"
RUN echo "root:${ROOT_PASSWORD}" | chpasswd
RUN useradd -g sudo test
COPY test/resources/common-auth /etc/pam.d/common-auth
USER test
# before running the sudo command, the /etc/shadow file will not be readable
RUN (cat /etc/shadow && echo "ERROR: test user should not be able to read the /etc/shadow file!" && exit 2) || true
# while running the sudo command verify that the now privileged user can read the /etc/shadow file
RUN echo "${ROOT_PASSWORD}" | sudo -S cat /etc/shadow

# the following is only there to satisfy vscode/linting
CMD ["/alp"]
LABEL Name="testing"
LABEL Version="0.0.0"
EXPOSE 8080