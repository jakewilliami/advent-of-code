# Leaderboard Interfaces

It is convenient to have interfaces to the leaderboard (both my private leaderboard for work, and my personal leaderboard).  This directory contains various projects for these.

The two primary subdirectories are:
  - [`winphysec/`](./winphysec/): displaying information about the private leaderboard I made for my old job at InPhySec; and
  - [`personal/`](./personal/): displaying information about my personal statistics.

Keep your environment variable file (`.env`) in this directory, as subdirectories symlink to it:
```dotenv
LEADERBOARD_ID=...
SESSION_COOKIE=...
YEAR=...
```
