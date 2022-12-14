# Day 1&mdash;Sonar Sweep

## Why do you have so many different implementations?

I thought I would give this day a go in some different languages.  It's a great way to understand a new language&mdash;the problem uses lists, for loops, if statements, reading files, and parsing strings as integers.

The languages I tried here are compiled languages as I thought it was only fair to test compiled against compiled.

## Benchmarking

```console
$ gcc -o day1_c day1.c  # C
# rustc -C opt-level=3 day1.rs -o day1_rs  # Rust
$ go build -o day1_go day1.go  # Go
$ nim c -o=day1_nim day1.nim  # Nim
$ zig cc -o day1_zig day1.zig  # Zig
$ ring2exe day1.ring && mv day1 day1_ring  # Ring
$ ghc day1.hs -o day1_hs -outputdir /tmp  # Haskell
$ buildapp --entry main --output day1_lisp --load day1.lisp # Common Lisp; compiled using Buildapp
$ hyperfine --warmup=3 -N --export-markdown=benchmark.md ./day1_c ./day1_rs ./day1_go ./day1_nim ./day1_zig ./day1_ring
```
