package main

import (
	"fmt"
	"golang.org/x/net/html"
	"io"
	"net/http"
	"net/http/cookiejar"
	"os"
	"strings"
)

const AOC_YEAR int = 2022

func main() {
	sessionCookie := GetSessionCookie()

	jar, err := cookiejar.New(nil)
	if err != nil {
		fmt.Println("[ERROR] creating cookie jar: ", err)
		os.Exit(1)
	}

	// https://stackoverflow.com/a/19386573
	client := &http.Client{
		Jar: jar,
	}

	url := fmt.Sprintf("https://adventofcode.com/%d/leaderboard/self", AOC_YEAR)
	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		fmt.Println("[ERROR] creating request: ", err)
		os.Exit(1)
	}

	AddReqHeaders(req, sessionCookie)

	// Get page
	resp, err := client.Do(req)
	if err != nil {
		fmt.Println("[ERROR] sending request: ", err)
		os.Exit(1)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		fmt.Println("[ERROR] ", resp.Status)
		os.Exit(1)
	}

	htm, err := io.ReadAll(resp.Body)
	if err != nil {
		fmt.Println("[ERROR] Failed to read response content: ", err)
		os.Exit(1)
	}

	// https://stackoverflow.com/a/38855264/
	// https://stackoverflow.com/a/46311885
	doc, _ := html.Parse(strings.NewReader(string(htm[:])))

	// Extract stats
	stats, err := ExtractStatsHtml(doc)
	if err != nil {
		fmt.Println("[ERROR] Failed to extract stats from HTML: ", err)
		os.Exit(1)
	}
	ShowStats(stats)
}
