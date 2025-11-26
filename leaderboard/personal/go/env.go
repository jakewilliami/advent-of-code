package main

import (
	"fmt"
	"os"
	"strconv"
	"time"

	"github.com/joho/godotenv"
)

func GetYear() int {
	if err := godotenv.Load(); err != nil {
		fmt.Println("[ERROR] Could not load .env file: ", err)
		os.Exit(1)
	}

	year := os.Getenv("YEAR")

	if year == "" {
		year = time.Now().Format("2006")
	}

	yearInt, err := strconv.Atoi(year)
	if err != nil {
		fmt.Println("[ERROR] Could not parse YEAR as int:", err)
		os.Exit(1)
	}

	return yearInt
}

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
