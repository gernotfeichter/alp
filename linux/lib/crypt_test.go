package lib

import (
	"errors"
	"fmt"
	log "github.com/sirupsen/logrus"
	"testing"
)

func Test_encrypt_decrypt(t *testing.T) {
	log.SetLevel(log.TraceLevel)
	type args struct {
		plaintext  string
		encryptKey string
		decryptKey string
	}
	tests := []struct {
		name string
		args args
		wantDecrypted string
		wanterr error
	}{
		{
			name: "encrypting and subsequent decrypting with the same key should yield the original text",
			args: args{plaintext: "abcdef", encryptKey: "passwordpasswordpasswordpassword", decryptKey: "passwordpasswordpasswordpassword"},
			wantDecrypted: "abcdef",
			wanterr: nil,
		},
		{
			name: "encrypting and subsequent decrypting with a different key should not yield the original text",
			args: args{plaintext: "abcdef", encryptKey: "passwordpasswordpasswordpassword", decryptKey: "01234567890123456789012345678901"},
			wantDecrypted: "see wanterr below!",
			wanterr: errors.New("cipher: message authentication failed"),
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(_ *testing.T) {
			enrypted, err := Encrypt(tt.args.plaintext, tt.args.encryptKey)
			log.Tracef("encrypted: %s", enrypted)
			if err != nil {
				log.Fatal(err)
			}
			decrypted, err := Decrypt(enrypted, tt.args.decryptKey)
			if fmt.Sprint(tt.wanterr) != fmt.Sprint(err) {
				log.Fatalf("Expected error: %s, but got: %s", tt.wanterr, err)
			}
			if err == nil && tt.wantDecrypted != decrypted {
				log.Fatalf("Expected: %s, but got: %s", tt.wantDecrypted, decrypted)
			}
		})
	}
}
