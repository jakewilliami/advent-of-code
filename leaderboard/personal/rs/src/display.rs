use super::{
    duration::CanonicalDuration,
    stats::{DayStats, Duration, Integer},
};
use num_format::{Locale, ToFormattedString};
use prettytable::{format, row, Table};
use std::collections::HashMap;
use std::fmt;

impl fmt::Display for Integer {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Integer::Some(n) => write!(f, "{}", n.to_formatted_string(&Locale::en)),
            Integer::Missing | Integer::Unknown => write!(f, ""),
        }
    }
}

impl fmt::Display for Duration {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Duration::Some(d) => {
                let duration = CanonicalDuration::from(*d);

                // Implementation stolen from:
                // https://github.com/jakewilliami/gastonle.ru/blob/dcfba8b2/src/duration.rs
                let mut parts = Vec::new();

                fn format_unit(val: usize, unit: &str) -> String {
                    let p = if val != 1 { "s" } else { "" };
                    format!("{} {}{}", val, unit, p)
                }

                if duration.weeks > 0 {
                    parts.push(format_unit(duration.weeks, "week"))
                }
                if duration.days > 0 {
                    parts.push(format_unit(duration.days, "day"))
                }
                if duration.hours > 0 {
                    parts.push(format_unit(duration.hours, "hour"))
                }
                if duration.minutes > 0 {
                    parts.push(format_unit(duration.minutes, "minute"))
                }
                if duration.seconds > 0 {
                    parts.push(format_unit(duration.seconds, "second"))
                }

                let canonicalised_duration = match parts.len() {
                    0 => "TODO: I don't know how we got here".to_string(),
                    1 => parts[0].to_owned(),
                    2 => {
                        let b = parts.pop().unwrap();
                        let a = parts.pop().unwrap();
                        format!("{a} and {b}",)
                    }
                    _ => {
                        let smallest = parts.pop().unwrap();
                        format!("{}, and {smallest}", parts.join(", "))
                    }
                };
                write!(f, "{}", &canonicalised_duration)
            }
            Duration::OverOneDay => write!(f, "> 24 hours"),
            Duration::Missing | Duration::Unknown => write!(f, ""),
        }
    }
}

pub fn display_stats(stats: HashMap<usize, DayStats>) {
    let mut table = Table::new();
    table.set_format(*format::consts::FORMAT_BOX_CHARS);
    table.add_row(row![
        "Year",
        "Day",
        "Time (P1)",
        "Rank (P1)",
        "Time (P2)",
        "Rank (P2)"
    ]);

    for i in 1..=25 {
        if let Some(day_stats) = stats.get(&(i as usize)) {
            let date = &day_stats.date;
            let (p1, p2) = (&day_stats.parts[0], &day_stats.parts[1]);
            table.add_row(row![
                &date.year, &date.day, &p1.time, &p1.rank, &p2.time, &p2.rank
            ]);
        }
    }

    table.printstd();
}
