package lib

import (
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"encoding/base64"
	"log"
)

func encryptAES(plaintext string, key string) string {
	block, err := aes.NewCipher([]byte(key))
	if err != nil {
		log.Fatal(err)
	}

	ciphertext := make([]byte, aes.BlockSize+len(plaintext))
	iv := ciphertext[:aes.BlockSize]
	if _, err := rand.Read(iv); err != nil {
		log.Fatal(err)
	}

	stream := cipher.NewCTR(block, iv)
	stream.XORKeyStream(ciphertext[aes.BlockSize:], []byte(plaintext))

	return base64.StdEncoding.EncodeToString(ciphertext)
}

func decryptAES(ciphertext string, key string) string {
	encrypted, err := base64.StdEncoding.DecodeString(ciphertext)
	if err != nil {
		log.Fatal(err)
	}

	block, err := aes.NewCipher([]byte(key))
	if err != nil {
		log.Fatal(err)
	}

	if len(encrypted) < aes.BlockSize {
		log.Fatal("ciphertext too short")
	}

	iv := encrypted[:aes.BlockSize]
	encrypted = encrypted[aes.BlockSize:]

	stream := cipher.NewCTR(block, iv)
	stream.XORKeyStream(encrypted, encrypted)

	return string(encrypted)
}