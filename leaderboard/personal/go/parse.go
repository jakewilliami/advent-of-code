package main

import (
	"bytes"
	"errors"
	"fmt"
	"golang.org/x/net/html"
	"io"
	"os"
	"strconv"
	"strings"
	"time"
)

func extractMainHtml(doc *html.Node) (*html.Node, error) {
	var body *html.Node
	var crawler func(*html.Node)
	crawler = func(node *html.Node) {
		if node.Type == html.ElementNode && node.Data == "main" {
			body = node
			return
		}
		for child := node.FirstChild; child != nil; child = child.NextSibling {
			crawler(child)
		}
	}
	crawler(doc)
	if body != nil {
		return body, nil
	}
	return nil, errors.New("Missing <main> in the node tree")
}

func renderNode(n *html.Node) string {
	var buf bytes.Buffer
	w := io.Writer(&buf)
	html.Render(w, n)
	return buf.String()
}

func parseMaybeInt(s string) IntStat {
	switch s {
	case "-":
		return IntStat{
			Type:  MissingInt,
			Value: 0,
		}
	default:
		n, err := strconv.Atoi(s)
		if err != nil {
			fmt.Println("[ERROR] Failed to parse integer: ", err)
		}
		return IntStat{
			Type:  ValidInt,
			Value: n,
		}
	}
}

func parseMaybeDuration(s string) DurationStat {
	switch s {
	case "-":
		return DurationStat{
			Type:     MissingDuration,
			Duration: time.Duration(0) * time.Second,
		}
	case ">24h":
		return DurationStat{
			Type:     OverADayDuration,
			Duration: time.Duration(24)*time.Hour + time.Duration(1)*time.Second,
		}
	default:
		t1 := time.Date(0, time.January, 1, 0, 0, 0, 0, time.UTC)
		t2, err := time.Parse("15:04:05", s)
		if err != nil {
			fmt.Println("[ERROR] Failed to parse time from string: ", err)
			os.Exit(1)
		}

		duration := t2.Sub(t1)
		return DurationStat{
			Type:     PreciseDuration,
			Duration: duration,
		}
	}
}

func ExtractStatsHtml(doc *html.Node) (map[int]DayStats, error) {
	statsHtml, err := extractMainHtml(doc)
	if err != nil {
		fmt.Println("[ERROR] Failed to extract main stats from HTML: ", err)
		os.Exit(1)
	}

	// We are going to parse the stats from string values because
	// there's no nice way to get the results otherwise.  The stats
	// is not in table format.

	// Render the main node as a string and split it into lines
	statsHtmlStr := html.UnescapeString(renderNode(statsHtml))
	statsStrLines := strings.Split(statsHtmlStr, "\n")
	statsStrLines = statsStrLines[3 : len(statsStrLines)-3]

	// Initialise the output map
	stats := make(map[int]DayStats)

	// Parse stats from each line
	for i := 0; i < len(statsStrLines); i++ {
		line := statsStrLines[i]
		words := strings.Fields(line)

		// Parse integer fields
		year := IntStat{
			Type:  ValidInt,
			Value: AOC_YEAR,
		}
		day := parseMaybeInt(words[0])
		rank1 := parseMaybeInt(words[2])
		score1 := parseMaybeInt(words[3])
		rank2 := parseMaybeInt(words[5])
		score2 := parseMaybeInt(words[6])

		// Parse time fields
		time1 := parseMaybeDuration(words[1])
		time2 := parseMaybeDuration(words[4])

		// Make day stats and push to map
		var parts [2]DayPartStats
		parts[0] = DayPartStats{
			Year:  year,
			Day:   day,
			Time:  time1,
			Rank:  rank1,
			Score: score1,
		}
		parts[1] = DayPartStats{
			Year:  year,
			Day:   day,
			Time:  time2,
			Rank:  rank2,
			Score: score2,
		}
		stats[day.Value] = DayStats{
			Year:  year,
			Day:   day,
			Parts: parts,
		}
	}
	return stats, nil
}
