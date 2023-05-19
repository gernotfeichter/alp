package lib

import (
	"log"
	"testing"
	"gotest.tools/v3/assert"
)

func Test_encrypt_decrypt_AES(t *testing.T) {
	plaintext := "secret-text"
	key := "passwordpassword"

	ciphertext := encryptAES(plaintext, key)
	decrypted := decryptAES(ciphertext, key)

	log.Println("Ciphertext:", ciphertext)
	log.Println("Decrypted:", decrypted)

	assert.Equal(t, decryptAES("cDx81ohYRJNmnpFpDdw/qs1aYoLtUOtDEOk1", key), plaintext) // ciphertext from this go implementation
	log.Println("First test succeeded")
	//assert.Equal(t, decryptAES("Nb5lHLauPblZHko1dM75gg==", key), plaintext) // ciphertext from dart implementation
	log.Println("decrypted=" + decryptAES("Nb5lHLauPblZHko1dM75gg==", key), plaintext)
}
