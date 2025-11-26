# AoC Private Leaderboard

I have made a private leaderboard for work (InPhySec), and have written a script [in Julia](./jl/) and Rust.

Required environment variables: `LEADERBOARD_ID` and `SESSION_COOKIE`.

> [!CAUTION]
>
> Year is currently hard coded; make sure you specify it in your environment variables.

## Quick Start

```shell
$ # Julia
$ cd jl/
$ julia --project parse_leaderboard.jl

$ # Rust (WARNING: SCRIPT UNFINISHED BUT JUST AN ATTEMPTED PORT OF THE JULIA VERSION)
$ cargo run
```
