package lib

import (
	"log"
	"testing"
	"gotest.tools/v3/assert"
)

func Test_encrypt_decrypt_AES(t *testing.T) {
	plaintext := "secret-text"
	key := "passwordpasswordpasswordpassword"

	ciphertext := encryptAES(plaintext, key)
	decrypted := decryptAES(ciphertext, key)

	log.Println("Ciphertext:", ciphertext)
	log.Println("Decrypted:", decrypted)

	assert.Equal(t, decryptAES("HklGGEqQEiBsulgkXhW0b+Wl7ijlMZsB7JCf", key), plaintext) // ciphertext from this go implementation
	log.Println("First test succeeded")
	assert.Equal(t, decryptAES("nIj/ThHqhT9lrBKM1kl4MA==", key), plaintext) // ciphertext from dart implementation

}
