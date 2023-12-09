use chrono;

#[derive(Debug)]
pub enum Integer {
    Some(usize),
    Missing,
    Unknown,
}

#[derive(Debug)]
pub enum Duration {
    Some(chrono::Duration),
    OverOneDay,
    Missing,
    Unknown,
}

#[derive(Debug, Clone)]
pub struct Date {
    pub day: usize,
    pub year: usize,
}

#[derive(Debug)]
pub struct DayPartStats {
    pub date: Date,
    pub part: usize,
    pub time: Duration,
    pub rank: Integer,
    pub score: Integer,
}

#[derive(Debug)]
pub struct DayStats {
    pub date: Date,
    pub parts: [DayPartStats; 2],
}
