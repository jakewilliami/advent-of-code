# AoC Personal

Pull/parse personal AoC stats.

Required environment variable: `SESSION_COOKIE`.

> [!NOTE]
>
> The reason there are different subdirectories with different implementations of the same script is entirely for my own edification, not for any practical reason.

> [!CAUTION]
>
> Year is currently hard coded; this should be changed in future to allow specification with user input.

## Quick Start

```
$ # Rust
$ cd rd/
$ cargo run

$ # Go
$ cd go/
$ go run ./

$ # Julia
$ cd jl/
$ julia --project main_local.jl  # NOTE: REQUIRES LOCAL DATA PASTED FROM FRONT-END AS STRING (EW)
$ julia --project main_remote.jl  # WARNING: REMOTE DATA COLLECTION NOT YET IMPLEMENTED
```
