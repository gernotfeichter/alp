# This Dockerfile is only used for testing

FROM golang:1.21

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
RUN apt-get update && apt-get install sudo && apt-get clean
RUN useradd -g sudo test
ENV SUDO_PASSWORD="sudo-password"
RUN echo "test:${SUDO_PASSWORD}" | chpasswd
COPY test/resources/common-auth /etc/pam.d/common-auth
USER test
# before running the sudo command, the /etc/shadow file will not be readable
RUN (cat /etc/shadow && echo "ERROR: test user should not be able to read the /etc/shadow file!" && exit 2) || true
# while running the sudo command verify that the now privileged user can read the /etc/shadow file
RUN echo "root password is: ${SUDO_PASSWORD}"
RUN echo "${SUDO_PASSWORD}" | sudo -S cat /etc/shadow

# the following is only there to satisfy vscode/linting
CMD ["/usr/sbin/alp"]
LABEL Name="testing"
LABEL Version="0.0.0"
EXPOSE 8080