use reqwest::{header::HeaderMap, Client};

pub async fn pull_leaderboard_data(
    leaderboard_id: String,
    session_cookie: String,
    year: String,
) -> serde_json::Map<String, serde_json::Value> {
    // Construct URI
    // let url = format!("https://adventofcode.com/{}/leaderboard/private/view/", &year);
    let url = format!("https://adventofcode.com/{}/leaderboard/self", &year);

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

    println!("{:?}", &body);
    let data: serde_json::Value =
        serde_json::from_str(&body).expect("The JSON response was not well defined");
    data.as_object().unwrap().clone()
}
