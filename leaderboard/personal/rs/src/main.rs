// #[macro_use]
// extern crate html5ever;
// extern crate markup5ever_rcdom as rcdom;

mod display;
mod duration;
mod parse;
mod request;
mod stats;

use dotenv::dotenv;
use std::env;

const AOC_YEAR: usize = 2021;

#[tokio::main]
async fn main() {
    dotenv().ok();

    let session_cookie =
        env::var("SESSION_COOKIE").expect("Could not find \"SESSION_COOKIE\" in .env");

    let html = request::pull_personal_stats(session_cookie).await;
    let stats = parse::extract_stats(html);
    display::display_stats(stats);
}
