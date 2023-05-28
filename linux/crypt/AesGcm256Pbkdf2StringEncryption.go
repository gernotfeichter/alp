// Source: https://github.com/java-crypto/cross_platform_crypto/tree/main/AesGcm256Pbkdf2StringEncryption

package crypt

import (
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"crypto/sha256"
  "encoding/base64"
  "io"
	"strings"
	"golang.org/x/crypto/pbkdf2"
)

func AesGcmPbkdf2EncryptToBase64(passphrase string, data string)(string) {
  PBKDF2_ITERATIONS := int(15000)
  salt := []byte(GenerateSalt32Byte())
  // derive key
  key := []byte(pbkdf2.Key([]byte(passphrase), salt, PBKDF2_ITERATIONS, 32, sha256.New))
  // encrypt
  plaintext := []byte(data)
  nonce := []byte(GenerateRandomNonce())
	block, err := aes.NewCipher(key)
	if err != nil {
		panic(err.Error())
	}
	aesGCM, err := cipher.NewGCM(block)
	if err != nil {
		panic(err.Error())
	}
  ciphertext := aesGCM.Seal(nil, nonce, plaintext, nil)
  // ciphertext hold the ciphertext | gcmTag
  ciphertextWithTagLength := int(len(ciphertext))
  ciphertextWithoutTag, gcmTag := ciphertext[:(ciphertextWithTagLength-16)], ciphertext[(ciphertextWithTagLength-16):]
  ciphertextWithoutTagBase64 := string(Base64Encoding(ciphertextWithoutTag))
  saltbase64 := string(Base64Encoding(salt))
  nonceBase64 := string(Base64Encoding(nonce))
  gcmTagBase64 := string(Base64Encoding(gcmTag))
  ciphertextCompleteBase64 := string(saltbase64 + ":" + nonceBase64 + ":" + ciphertextWithoutTagBase64 + ":" + gcmTagBase64) 
  return ciphertextCompleteBase64
}

func AesGcmPbkdf2DecryptFromBase64(passphrase string, ciphertextCompleteBase64 string)(string) {
  PBKDF2_ITERATIONS := int(15000)
  data := strings.Split(ciphertextCompleteBase64, ":") 
  salt := []byte(Base64Decoding(data[0]))
  nonce := []byte(Base64Decoding(data[1]))
  ciphertext := []byte(Base64Decoding(data[2]))
  gcmTag := []byte(Base64Decoding(data[3]))
  ciphertextCompleteLength := int(len(ciphertext) + len(gcmTag))
  ciphertextComplete := make([]byte, ciphertextCompleteLength)
  ciphertextComplete = append(ciphertext[:], gcmTag[:]...)
  // derive key
  key := []byte(pbkdf2.Key([]byte(passphrase), salt, PBKDF2_ITERATIONS, 32, sha256.New))
  // decrypt
  block, err := aes.NewCipher(key)
	if err != nil {
		panic(err.Error())
	}
	aesGCM, err := cipher.NewGCM(block)
	if err != nil {
		panic(err.Error())
	}
  plaintext, err := aesGCM.Open(nil, nonce, ciphertextComplete, nil)
	if err != nil {
		panic(err.Error())
	}
  return string(plaintext)
}

func GenerateSalt32Byte()([]byte) {
  salt := make([]byte, 32)
	if _, err := io.ReadFull(rand.Reader, salt); err != nil {
	  panic(err.Error())
	}
  return salt
}

func GenerateRandomNonce()([]byte) {
  nonce := make([]byte, 12)
	if _, err := io.ReadFull(rand.Reader, nonce); err != nil {
	  panic(err.Error())
	}
  return nonce
}

func Base64Encoding(input []byte)(string) {
  return base64.StdEncoding.EncodeToString(input)
}

func Base64Decoding(input string)([]byte) {
  data, err := base64.StdEncoding.DecodeString(input)
	if err != nil {
		return data
	}
  return data
}
