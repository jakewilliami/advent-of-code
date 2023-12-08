#[macro_use]
extern crate html5ever;
extern crate markup5ever_rcdom as rcdom;

mod parse;
mod request;

use dotenv::dotenv;
use parse::parse_html;
use std::env;

#[tokio::main]
async fn main() {
    dotenv().ok();

    let session_cookie =
        env::var("SESSION_COOKIE").expect("Could not find \"SESSION_COOKIE\" in .env");

    let res = request::pull_leaderboard_data(session_cookie).await;
    parse::parse_html(res);
    // println!("{:?}", res);
    return;
}
