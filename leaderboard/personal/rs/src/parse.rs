use super::{
    stats::{Date, DayPartStats, DayStats, Duration, Integer},
    AOC_YEAR,
};
use chrono::{self, NaiveTime};
use scraper::{Html, Selector};
use std::collections::HashMap;

// https://github.com/causal-agent/scraper
// Uses html5 under the hood
pub fn extract_stats(html: String) -> HashMap<usize, DayStats> {
    let document = Html::parse_document(&html);
    let main_selector = Selector::parse("main").unwrap();
    let article_selector = Selector::parse("article").unwrap();
    let pre_selector = Selector::parse("pre").unwrap();

    let main = document.select(&main_selector).next().unwrap();
    let article = main.select(&article_selector).next().unwrap();
    let pre = article.select(&pre_selector).next().unwrap();

    extract_stats_from_str(pre.inner_html())
}

fn extract_stats_from_str(stats: String) -> HashMap<usize, DayStats> {
    let mut map: HashMap<usize, DayStats> = HashMap::new();

    // Skip the preamble (headers) that we don't care about
    for line in stats.lines().skip(2) {
        // TODO: consider using something like:
        //   - github.com/veddan/rust-htmlescape; or
        //   - github.com/phaazon/html-entities.
        let line = line.replace("&gt;", ">");
        let words: Vec<_> = line.split_whitespace().collect();

        // Parse integers
        let day = parse_int_from_stats(words[0]).unwrap(); // We should always have a day
        let rank1 = parse_int_from_stats(words[2]);
        let score1 = parse_int_from_stats(words[3]);
        let rank2 = parse_int_from_stats(words[5]);
        let score2 = parse_int_from_stats(words[6]);

        // Parse durations
        let time1 = parse_duration_from_stats(words[1]);
        let time2 = parse_duration_from_stats(words[4]);

        // Make day stats and push to map
        let parts = DayStats {
            date: Date {
                day,
                year: AOC_YEAR,
            },
            parts: [
                DayPartStats {
                    date: Date {
                        day,
                        year: AOC_YEAR,
                    },
                    part: 1,
                    time: time1,
                    rank: rank1,
                    score: score1,
                },
                DayPartStats {
                    date: Date {
                        day,
                        year: AOC_YEAR,
                    },
                    part: 2,
                    time: time2,
                    rank: rank2,
                    score: score2,
                },
            ],
        };
        map.insert(day, parts);
    }
    map
}

fn parse_int_from_stats(n: &str) -> Integer {
    match n {
        "-" => Integer::Missing,
        _ => match n.parse::<usize>() {
            Ok(n) => Integer::Some(n),
            Err(err) => {
                println!("[WARNING] Failed to parse integer {n:?} as type `usize': {err}");
                Integer::Unknown
            }
        },
    }
}

fn parse_duration_from_stats(d: &str) -> Duration {
    match d {
        "-" => Duration::Missing,
        ">24h" => Duration::OverOneDay,
        _ => {
            let t1 = NaiveTime::parse_from_str(d, "%H:%M:%S");
            match t1 {
                Ok(t1) => {
                    let t2 = NaiveTime::from_hms_opt(0, 0, 0).unwrap();
                    let duration = t1.signed_duration_since(t2);
                    Duration::Some(duration)
                }
                Err(err) => {
                    println!("[WARNING] Failed to parse time string {d:?} as type `chrono::Duration': {err}");
                    Duration::Unknown
                }
            }
        }
    }
}

impl Integer {
    fn unwrap(&self) -> usize {
        match self {
            Integer::Some(n) => *n,
            _ => panic!("Could not unwrap custom `Integer' type {:?}", self),
        }
    }
}
