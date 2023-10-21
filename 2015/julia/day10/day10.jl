using IterTools

function look_and_say(data_str::String, iterations::Int)
    io = IOBuffer()
    print(io, data_str)
    data = take!(io)

    for _ in 1:iterations
        i = 1
        while true
            c₁, j = data[i], 1
            while (i + j) <= length(data) && data[i + j] == c₁
                j += 1
            end
            print(io, j, Char(c₁))
            (i + j) <= length(data) || break
            i += j
        end
        data = take!(io)
    end

    return String(data)
end

# Inspired by: https://www.reddit.com/r/adventofcode/comments/3w6h3m/comment/cxtsnof/
function look_and_say_groupby(initial_state::String, iterations::Int)
    data, io = initial_state, IOBuffer()

    for _ in 1:iterations
        for v in groupby(identity, data)
            print(io, length(v), first(v))
        end
        data = String(take!(io))
    end

    return data
end

part1(data::String) = length(look_and_say(data, 40))
part2(data::String) = length(look_and_say(data, 50))

function main()
    data = String(readchomp("data10.txt"))

    part1_solution = part1(data)
    @assert part1_solution == 360154
    println("Part 1: $part1_solution")

    part2_solution = part2(data)
    @assert part2_solution == 5103798
    println("Part 2: $part2_solution")
end

main()
