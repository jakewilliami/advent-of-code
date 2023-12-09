// Implementation stolen from:
//   https://github.com/jakewilliami/gastonle.ru/blob/dcfba8b2/src/duration.rs
// Decidedly a better implementation than the one I wrote in ../../../winphysec/src/dates.rs
// It's still not amazing.  I implemented it quite fast.  Probably doesn't compare to
// Julia's `canonicalize' function:
//   https://docs.julialang.org/en/v1/stdlib/Dates/#Dates.canonicalize
// But it's fine for my needs.  There must be an implementation of this out there becuase
// it has come up a few times, but I can't be bothered looking and downloading one when I
// can just copy and old, buggy code I wrote (smile)

use chrono::Duration;

const MILLISECONDS_IN_SECOND: usize = 1000;
const SECONDS_IN_MINUTE: usize = 60;
const SECONDS_IN_HOUR: usize = SECONDS_IN_MINUTE * 60;
const SECONDS_IN_DAY: usize = SECONDS_IN_HOUR * 24;
const SECONDS_IN_WEEK: usize = SECONDS_IN_DAY * 7;

pub struct CanonicalDuration {
    // TODO: implement this for months and years (tricky)
    // pub years: usize,
    // pub months: usize,
    pub weeks: usize,
    pub days: usize,
    pub hours: usize,
    pub minutes: usize,
    pub seconds: usize,
}

impl From<Duration> for CanonicalDuration {
    fn from(duration: Duration) -> Self {
        let duration_ms = duration.num_milliseconds() as f64;
        let mut seconds = (duration_ms / MILLISECONDS_IN_SECOND as f64).floor();
        let weeks = (seconds / SECONDS_IN_WEEK as f64).floor() as usize;
        seconds -= (weeks * SECONDS_IN_WEEK) as f64;
        let days = (seconds / SECONDS_IN_DAY as f64).floor() as usize;
        seconds -= (days * SECONDS_IN_DAY) as f64;
        let hours = (seconds / SECONDS_IN_HOUR as f64).floor() as usize;
        seconds -= (hours * SECONDS_IN_HOUR) as f64;
        let minutes = (seconds / SECONDS_IN_MINUTE as f64).floor() as usize;
        seconds -= (minutes * SECONDS_IN_MINUTE) as f64;
        let seconds = seconds as usize;

        CanonicalDuration {
            weeks,
            days,
            hours,
            minutes,
            seconds,
        }
    }
}
