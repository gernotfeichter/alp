# This Dockerfile is only used for testing

FROM golang:1.26

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

# Build the mock android server that answers the concurrent auth requests.
# The two endpoints (slow 127.0.0.1:18081, fast 127.0.0.1:18082) are used as
# the alp targets; both answer with authentication success, but only the fast
# one responds quickly.
COPY test/docker-scenarios/parallel-first-outcome-wins/ test/docker-scenarios/parallel-first-outcome-wins/
RUN go build -o /usr/sbin/alp-mock ./test/docker-scenarios/parallel-first-outcome-wins/mock/

# Test
RUN apt-get update && apt-get install -y sudo && apt-get clean
RUN useradd test
COPY test/docker-scenarios/parallel-first-outcome-wins/alp.yaml /etc/alp/alp.yaml
COPY test/resources/common-auth /etc/pam.d/common-auth
USER test
# This is the main line to be tested here: the mock server runs in the
# background, then an authentication is attempted via su root, which triggers
# the alp auth request through pam_exec. alp must send its requests to both
# targets in parallel, so the fast endpoint's success is the first outcome and
# the whole thing finishes well before the slow endpoint's delay (12s).
RUN /usr/sbin/alp-mock & \
    MOCK_PID=$! ; \
    sleep 1 ; \
    start=$(date +%s) ; \
    su root ; \
    rc=$? ; \
    end=$(date +%s) ; \
    kill "$MOCK_PID" 2>/dev/null || true ; \
    elapsed=$((end-start)) ; \
    echo "su root rc=$rc, elapsed=${elapsed}s" ; \
    [ "$rc" -eq 0 ] || { echo "ERROR: authentication did not succeed"; exit 1; } ; \
    [ "$elapsed" -lt 8 ] || { echo "ERROR: requests were NOT executed in parallel (took ${elapsed}s, expected <8s)"; exit 1; }

# the following is only there to satisfy vscode/linting
CMD ["/usr/sbin/alp"]
LABEL Name="testing"
LABEL Version="0.0.0"
EXPOSE 8080