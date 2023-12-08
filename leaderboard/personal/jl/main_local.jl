# https://adventofcode.com/2022/leaderboard/self
# Copy the statistics from the previous URL and this will parse them.

using Dates
using Statistics

using Printf

struct AoCStats
    day::Int
    time1::Time
    time2::Union{Time, Nothing}
    rank1::Int
    rank2::Union{Int, Nothing}
end

function parse_stats(S::AbstractString)
    S′ = split(S, '\n')
    S′′ = split.(S′)

    A = AoCStats[]
    for v in S′′
        isempty(v) && continue
        s = AoCStats(
            parse(Int, v[1]),                         # day
            Time(v[2]),                               # time 1
            v[5] == "-" ? nothing : Time(v[5]),       # time 2
            parse(Int, v[3]),                         # rank 1
            v[6] == "-" ? nothing : parse(Int, v[6])  # rank 2
        )

        push!(A, s)
    end

    return A
end

const S = """\
 25   01:38:00   3318      0          -      -      -
 23   02:51:06   3773      0   02:54:42   3596      0
 22   01:22:29   2271      0          -      -      -
 21   01:38:31   5034      0          -      -      -
 20   02:09:36   3164      0          -      -      -
 18   00:34:37   3409      0   10:00:07   9726      0
 17   08:32:41   7967      0          -      -      -
 15   01:49:18   6371      0   03:25:03   5316      0
 14   01:25:48   6073      0   01:35:18   5527      0
 13   06:02:28  14407      0   06:18:55  13620      0
 12   02:01:15   7265      0   02:44:31   8101      0
 11   00:51:00   4767      0   03:31:51   9075      0
 10   00:20:53   4239      0   04:38:12  17658      0
  9   01:04:29   8828      0   03:58:09  13851      0
  8   00:43:19   8074      0   01:01:11   6560      0
  7   07:23:58  30552      0   07:39:28  29237      0
  6   00:08:24   4944      0   00:09:05   3935      0
  5   00:22:15   3381      0   00:25:07   2990      0
  4   00:12:03   5740      0   00:12:34   3667      0
  3   00:11:12   3368      0   00:17:37   3048      0
  2   00:18:48   7701      0   00:28:11   7554      0
  1   00:07:21   4112      0   00:09:57   3691      0
"""

function main()
    A = parse_stats(S)

    println("Top 10 days/parts by rank:")
    A′ = []
    for s in A
        push!(A′, (s.day, 1, s.rank1))
        isnothing(s.rank2) && continue
        push!(A′, (s.day, 2, s.rank2))
    end
    sort!(A′, by = last)
    @printf("%7s  %5s  %5s\n", "Day", "Part", "Rank")
    for (d, p, r) in A′[1:10]
        @printf("%7d  %5d  %5d\n", d, p, r)
    end
    println()

    println("Top 10 complete days by time:")
    A′ = []
    for s in A
        push!(A′, (s.day, 1, s.time1))
    end
    sort!(A′, by = last)
    @printf("%7s  %5s  %5s\n", "Day", "Part", "Time")
    t₀ = Time("00:00:00")
    for (d, p, t) in A′[1:10]
        @printf("%7d  %5d  %-5s\n", d, p, canonicalize(t - t₀))
    end
    println()

    println("Best time after part 1:")
    A′′ = filter(s -> !isnothing(s.time2), A)
    t, i = findmin(s.time2 - s.time1 for s in A′′)
    for _ in 1:4
        deleteat!(A′′, i)
        t, i = findmin(s.time2 - s.time1 for s in A′′)
    end
    d = A′′[i].day
    t′ = canonicalize(t)
    println("    Day $d: $t′")
end

main()
