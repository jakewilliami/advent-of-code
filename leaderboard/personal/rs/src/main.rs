// #[macro_use]
// extern crate html5ever;
// extern crate markup5ever_rcdom as rcdom;

mod display;
mod duration;
mod parse;
mod request;
mod stats;

use chrono::prelude::*;
use dotenv::dotenv;
use lazy_static;
use std::env;

lazy_static::lazy_static! {
    pub static ref AOC_YEAR: usize = {
        let year_current = Utc::now().year().to_string();
        let year_str = env::var("YEAR").unwrap_or(year_current);
        year_str
            .parse::<usize>()
            .expect("Could not parse YEAR as an integer")
    };
}

#[tokio::main]
async fn main() {
    dotenv().ok();

    let session_cookie =
        env::var("SESSION_COOKIE").expect("Could not find \"SESSION_COOKIE\" in .env");

    let html = request::pull_personal_stats(session_cookie).await;
    let stats = parse::extract_stats(html);
    display::display_stats(stats);
}
