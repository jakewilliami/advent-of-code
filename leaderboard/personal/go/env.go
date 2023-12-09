package main

import (
	"fmt"
	"os"

	"github.com/joho/godotenv"
)

func GetSessionCookie() string {
	if err := godotenv.Load(); err != nil {
		fmt.Println("[ERROR] Could not load .env file: ", err)
		os.Exit(1)
	}

	sessionCookie := os.Getenv("SESSION_COOKIE")

	if sessionCookie == "" {
		fmt.Println("[ERROR] SESSION_COOKIE not set in environment variables")
		os.Exit(1)
	}

	return sessionCookie
}
