# syntax=docker/dockerfile:1

FROM golang:1.19

# Set destination for COPY
WORKDIR /ws

# Download Go modules
COPY go.mod go.sum ./
RUN go mod download

# Copy the source code. Note the slash at the end, as explained in
# https://docs.docker.com/engine/reference/builder/#copy
COPY *.go ./

# Build
RUN CGO_ENABLED=0 GOOS=linux go build -o /app
RUN useradd test

USER test

COPY common-auth /etc/pam.d/common-auth

RUN su root


# Run
CMD ["/app"]
