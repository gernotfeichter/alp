// Source: https://github.com/java-crypto/cross_platform_crypto/tree/main/AesGcm256Pbkdf2StringEncryption

package crypt

import (
	"testing"

	"github.com/magiconair/properties/assert"
	log "github.com/sirupsen/logrus"
)

func TestAesGcmPbkdf2EncryptToBase64(t *testing.T) {
	type args struct {
		passphrase string
		data       string
	}
	tests := []struct {
		name string
		args args
		want string
	}{
		{
			name: "encrypt string",
			args: args{
				passphrase: "GYTpQ8GRE23YOgB1DK0FBwUATnKPJliW",
				data: "{\"secret\":\"abc\"}",
			},
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			encrypted := AesGcmPbkdf2EncryptToBase64(tt.args.passphrase, tt.args.data)
			log.Infof("encrypted=%s", encrypted)
			decrypted := AesGcmPbkdf2DecryptFromBase64(tt.args.passphrase, encrypted)
			assert.Equal(t, tt.args.data, decrypted)
		})
	}
}
