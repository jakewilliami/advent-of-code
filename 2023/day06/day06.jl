function parse_input(input_file::String)
    L = readlines(input_file)
    Ts, Ds = getindex.(split.(L, ":"), 2)

    # Format for part 1
    Ti, Di = parse.(Int, split(Ts)), parse.(Int, split(Ds))
    @assert length(Ti) == length(Di)
    A = Tuple{Int, Int}[(Ti[i], Di[i]) for i in 1:length(Ti)]

    # Format for part 2
    Ts, Ds = join(split.(Ts)), join(split.(Ds))
    Ti, Di = parse.(Int, (Ts, Ds))
    B = [Ti, Di]

    return A, B
end

race_dist(ht, t) = ht*(t - ht)
n_ways_to_win_race(t, d) = sum(race_dist(ht, t) > d for ht in 0:t)

part1(data) = prod(n_ways_to_win_race(t, d) for (t, d) in data)
part2(data) = n_ways_to_win_race(data...)

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
