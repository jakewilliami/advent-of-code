package main

import (
	"io"
	"bytes"
    "errors"
    "golang.org/x/net/html"
)

func ExtractStatsHtml(doc *html.Node) (*html.Node, error) {
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
    return nil, errors.New("Missing <body> in the node tree")
}

func renderNode(n *html.Node) string {
    var buf bytes.Buffer
    w := io.Writer(&buf)
    html.Render(w, n)
    return buf.String()
}
