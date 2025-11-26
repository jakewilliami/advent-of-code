use super::AOC_YEAR;
use reqwest::{header::HeaderMap, Client};

pub async fn pull_personal_stats(session_cookie: String) -> String {
    // Construct URI
    let url = format!("https://adventofcode.com/{}/leaderboard/self", *AOC_YEAR);

    // Set session cookie
    let mut headers = HeaderMap::new();
    headers.insert(
        "Cookie",
        format!("session={}", session_cookie).parse().unwrap(),
    );

    // Make request
    let client = Client::new();
    let res = client
        .get(url)
        .headers(headers)
        .send()
        .await
        .expect("Failed to access URL for workplace leaderboard");

    let body = res
        .text()
        .await
        .expect("Failed to retrieve body of response");

    body
}
