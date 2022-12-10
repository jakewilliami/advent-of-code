using AdventOfCode.Multidimensional


# Parse Input

const DIRECTIONS = cardinal_directions(2)

@enum Direction left=1 up down right

const CHAR_DIR_MAP = Dict{Char, Direction}(k => Direction(v) for (k, v) in zip("LUDR", 1:4))

const INST_DIR = Dict{Direction, CartesianIndex{2}}(CHAR_DIR_MAP[c] => DIRECTIONS[Int(CHAR_DIR_MAP[c])] for c in "LUDR")

struct Instruction
    direction::Direction
    n::Int
end

direction_modifier(direction::Direction) = INST_DIR[direction]

function parse_input(data_file::String)
    data = Instruction[]
    for line in eachline(data_file)
        a, b = split(line)
        c = only(a)
        n = parse(Int, b)
        d = CHAR_DIR_MAP[c]
        push!(data, Instruction(d, n))
    end
    return data
end

adjust_tail(ti::CartesianIndex{2}, hi::CartesianIndex{2}) =
    ti + direction(hi - ti)


# Part 1

function part1(instructions::Vector{Instruction})
    s = Set()
    hi, ti = CartesianIndex(0, 0), CartesianIndex(0, 0)

    for instruction in instructions
        for _ in 1:instruction.n
            hi += direction_modifier(instruction.direction)
            if !areadjacent(hi, ti)
                ti = adjust_tail(ti, hi)
            end
            push!(s, ti)
        end
    end

    return length(s)
end


# Part 2

function part2(instructions::Vector{Instruction})
    s = Set()
    tis = [CartesianIndex(0, 0) for _ in 1:10]

    for instruction in instructions
        for _ in 1:instruction.n
            tis[1] += direction_modifier(instruction.direction)
            for j in 2:length(tis)
                if !areadjacent(tis[j - 1], tis[j])
                    tis[j] = adjust_tail(tis[j], tis[j - 1])
                end
            end
            push!(s, tis[end])
        end
    end

    return length(s)
end


# Main

function main()
    data = parse_input("data09.txt")

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == 5619
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    @assert part2_solution == 2376
    println("Part 2: $part2_solution")
end

main()
