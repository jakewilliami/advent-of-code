package main

import (
	"net/http"
    "net/http/cookiejar"
	"fmt"
	"os"
	"io"
    "golang.org/x/net/html"
	"strings"
)

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

	url := "https://adventofcode.com/2021/leaderboard/self"
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
	doc, _ := html.Parse(strings.NewReader(string(htm[:])))
	
	// https://stackoverflow.com/a/46311885
	// htmlTokens := html.NewTokenizer(resp.Body)

	// Extract stats
	statsHtml, err := ExtractStatsHtml(doc)
    if err != nil {
        return
    }
    body := renderNode(statsHtml)
    fmt.Println(body)

	// TODO: parse response

	/*isMain := false
loop:
    for {
        tt := htmlTokens.Next()
        fmt.Printf("%T", tt)
        switch tt {
        case html.ErrorToken:
            fmt.Println("End")
            break loop
        case html.TextToken:
			if isMain {
				fmt.Println(tt)
			}
        case html.StartTagToken:
            t := htmlTokens.Token()
			if t.Data == "main" {
				isMain = !isMain
                fmt.Println("We found the main!")
			}
        }
    }*/
}
