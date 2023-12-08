use reqwest::{header::HeaderMap, Client};

// const BASE_URI: &str = "https://adventofcode.com/2022/leaderboard/private/view/";
const BASE_URI: &str = "https://adventofcode.com/2022/leaderboard/self";

pub async fn pull_leaderboard_data(session_cookie: String) -> String {
    // Construct URI
    let url = format!("{}", BASE_URI);

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
