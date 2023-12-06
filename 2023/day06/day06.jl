struct RaceRecord
    t::Int  # Record time
    d::Int  # Record distance
end

struct RaceTactic
    ht::Int  # Time spent holding the button
end

function parse_input(input_file::String)
    L = readlines(input_file)
    Ts, Ds = getindex.(split.(L, ":"), 2)

    # Format for part 1
    Ti, Di = parse.(Int, split(Ts)), parse.(Int, split(Ds))
    @assert length(Ti) == length(Di)
    A = RaceRecord[RaceRecord(Ti[i], Di[i]) for i in 1:length(Ti)]

    # Format for part 2
    Ts, Ds = join(split.(Ts)), join(split.(Ds))
    Ti, Di = parse.(Int, (Ts, Ds))
    B = RaceRecord(Ti, Di)

    return A, B
end

# Holding down the button for `ht' milliseconds, how far does your boat
# go with a total time of `t' milliseconds?  (Answer in millimeters.)
# Note: your boat has a starting speed of 0 mm/ms.  For each ms you take
# holding down the button, the boat's speed increases by one mm/ms.
race_distance(r::RaceTactic, t::Int) = r.ht*(t - r.ht)

# Does this race tactic win against the record?
wins(t::RaceTactic, r::RaceRecord) = race_distance(t, r.t) > r.d

# Looking through every amount of time to hold down the button at the
# beginning of the race, we can calculate the distance the boat goes for
# that race tactic, and determine whether it beats the record.
ways_to_win(r::RaceRecord) = sum(wins(RaceTactic(ht), r) for ht in 1:r.t)

part1(data::Vector{RaceRecord}) = prod(ways_to_win(r) for r in data)
part2(data::RaceRecord) = ways_to_win(data)

function main()
    data1, data2 = parse_input("data06.txt")

    # Part 1
    part1_solution = part1(data1)
    @assert part1_solution == 2344708
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data2)
    @assert part2_solution == 30125202
    println("Part 2: $part2_solution")
end

main()
