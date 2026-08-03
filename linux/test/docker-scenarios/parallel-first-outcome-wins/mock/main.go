// Mock android "server" used only by the parallel-first-outcome-wins test
// scenario. It serves two endpoints on localhost:
//
//	127.0.0.1:18081 - slow: answers an auth request positively after a delay
//	127.0.0.1:18082 - fast: answers an auth request positively immediately
//
// Even though alp contract the slow endpoint is listed as the first target in
// alp.yaml, the fast endpoint should win because requests are issued in
// parallel and the first outcome (here: success) decides.

package main

import (
	"crypto/md5"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"

	"github.com/gernotfeichter/alp/crypt"
)

const (
	key              = "test-key-parallel-first-outcome"
	pbkdf2Iterations = 15000
	slowAddr         = "127.0.0.1:18081"
	fastAddr         = "127.0.0.1:18082"
	slowDelay        = 12 * time.Second
)

// handler returns an auth handler that sleeps `delay` before answering. It
// mirrors the alp protocol: it echoes back the md5 of the encrypted request it
// received and returns a fresh encrypted response granting authentication.
func handler(delay time.Duration) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		if delay > 0 {
			time.Sleep(delay)
		}
		body, err := io.ReadAll(r.Body)
		if err != nil {
			w.WriteHeader(http.StatusBadRequest)
			return
		}
		var req struct {
			EncryptedMessage string `json:"encryptedMessage"`
		}
		if err := json.Unmarshal(body, &req); err != nil {
			w.WriteHeader(http.StatusBadRequest)
			return
		}

		response := struct {
			EncryptedMessage        string `json:"encryptedMessage"`
			RequestMessageSignature string `json:"requestMessageSignature"`
		}{
			EncryptedMessage: crypt.AesGcmPbkdf2EncryptToBase64(
				key,
				`{"auth":true}`,
				pbkdf2Iterations),
			RequestMessageSignature: fmt.Sprintf("%x", md5.Sum([]byte(req.EncryptedMessage))),
		}

		w.Header().Set("Content-Type", "application/json")
		if err := json.NewEncoder(w).Encode(response); err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			return
		}
	}
}

func main() {
	fastMux := http.NewServeMux()
	fastMux.HandleFunc("/auth", handler(0))

	slowMux := http.NewServeMux()
	slowMux.HandleFunc("/auth", handler(slowDelay))

	go func() {
		if err := http.ListenAndServe(fastAddr, fastMux); err != nil {
			panic(err)
		}
	}()

	if err := http.ListenAndServe(slowAddr, slowMux); err != nil {
		panic(err)
	}
}
