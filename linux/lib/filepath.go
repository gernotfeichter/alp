package lib

import (
	"fmt"
	"os"
	"path/filepath"
)

func CreateFileWithPath(filePath string, fileContent string, mode os.FileMode) error {
	dirPath := filepath.Dir(filePath)

	// Create all missing folders
	err := os.MkdirAll(dirPath, os.ModePerm)
	if err != nil {
		return fmt.Errorf("failed to create folders: %v", err)
	}

	// Create the file with the desired content
	err = os.WriteFile(filePath, []byte(fileContent), mode)
	if err != nil {
		return fmt.Errorf("failed to create file: %v", err)
	}

	return nil
}