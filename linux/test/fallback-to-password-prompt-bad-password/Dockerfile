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
RUN useradd test
COPY test/fallback-to-password-prompt-bad-password/common-auth /etc/pam.d/common-auth
USER test
# this is the main line to be tested here
RUN ((echo "wrong-password" | sudo -S cat /etc/shadow") && exit 2) || true

# the following is only there to satisfy vscode/linting
CMD ["/alp"]
LABEL Name="testing"
LABEL Version="0.0.0"
EXPOSE 8080