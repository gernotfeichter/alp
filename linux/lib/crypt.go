package lib

// tribute: code was taken/adapted from https://tutorialedge.net/golang/go-encrypt-decrypt-aes-tutorial/

import (
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"io"
	log "github.com/sirupsen/logrus"
)

func Encrypt(plaintext string, key string) string {
	validateKey(key)
	gcm := initCipher(key)
	nonce := make([]byte, gcm.NonceSize())
	if _, err := io.ReadFull(rand.Reader, nonce); err != nil {
		log.Fatalf("Could not seed nonce: %s", err)
	}
	return string(gcm.Seal(nonce, nonce, []byte(plaintext), nil))
}

func Decrypt(ciphertext string, key string) string {
	validateKey(key)
	gcm := initCipher(key)
	nonceSize := gcm.NonceSize()
	if len([]byte(ciphertext)) < nonceSize {
		log.Fatalf("Length of ciphertext smaller than nonceSize")
	}
	nonce, ciphertext := ciphertext[:nonceSize], ciphertext[nonceSize:]
	plaintext, err := gcm.Open(nil, []byte(nonce), []byte(ciphertext), nil)
	if err != nil {
		log.Fatalf("Coud not decrypt: %s", err)
	}
	return string(plaintext)
}

func initCipher(key string) cipher.AEAD {
	c, err := aes.NewCipher([]byte(key))
	if err != nil {
		log.Tracef("Key=%s", key)
		log.Fatalf("Could not create cipher from given key. Hiding the key - set -l trace to see it! %s", err)
	}
	gcm, err := cipher.NewGCM(c)
	if err != nil {
		log.Fatalf("Could not execute GCM: %s", err)
	}
	return gcm
}

func validateKey(key string) {
	keySize := len(key)
	if keySize != 32 {
		log.Fatalf("Expected a key size of 32, got: %d", keySize)
	}
}
