package lib

// tribute: code was taken/adapted from https://tutorialedge.net/golang/go-encrypt-decrypt-aes-tutorial/

import (
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"errors"
	"fmt"
	"io"

	log "github.com/sirupsen/logrus"
)

func Encrypt(plaintext string, key string) (string, error) {
	validateKey(key)
	gcm, err := initCipher(key)
	if err != nil {
		return "", err
	}
	nonce := make([]byte, gcm.NonceSize())
	if _, err := io.ReadFull(rand.Reader, nonce); err != nil {
		log.Fatalf("Could not seed nonce: %s", err)
	}
	return string(gcm.Seal(nonce, nonce, []byte(plaintext), nil)), nil
}

func Decrypt(ciphertext string, key string) (string, error) {
	validateKey(key)
	gcm, err := initCipher(key)
	if err != nil {
		return "", err
	}
	nonceSize := gcm.NonceSize()
	if len([]byte(ciphertext)) < nonceSize {
		return "", errors.New("length of ciphertext smaller than nonceSize")
	}
	nonce, ciphertext := ciphertext[:nonceSize], ciphertext[nonceSize:]
	plaintext, err := gcm.Open(nil, []byte(nonce), []byte(ciphertext), nil)
	if err != nil {
		return "", err
	}
	return string(plaintext), nil
}

func initCipher(key string) (cipher.AEAD, error) {
	c, err := aes.NewCipher([]byte(key))
	if err != nil {
		log.Tracef("Key=%s", key)
		return nil, err
	}
	gcm, err := cipher.NewGCM(c)
	if err != nil {
		return nil, err
	}
	return gcm, nil
}

func validateKey(key string) error {
	keySize := len(key)
	if keySize != 32 {
		return fmt.Errorf("expected a key size of 32, got: %d", keySize)
	}
	return nil
}
