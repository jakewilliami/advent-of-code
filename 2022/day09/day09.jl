# Indexing stuff

# Get a list of cartesian direction modifiers
# Copied from yesterday's solution, which was adapted from day 11, 2020
function cartesian_directions(dim::Int; exclude_diag::Bool = true)
    T = Int
    𝟎 = ntuple(_ -> zero(T), dim)
    dir_itr = Base.Iterators.product([-one(T):one(T) for i in one(T):dim]...)

    # The sum of the absolute values of the elements in a diagonal coordinate
    # is always equal to the number of dimensions because, in a diagonal coordinate,
    # all the elements have a value of either 1 or -1
    fltr(t) = exclude_diag ? sum(abs.(t)) != dim : true

    return CartesianIndex{dim}[CartesianIndex(t) for t in dir_itr if t ≠ 𝟎 && fltr(t)]
end

const ALL_DIRECTIONS = cartesian_directions(2, exclude_diag = false)

are_adjacent(i::CartesianIndex{N}, j::CartesianIndex{N}) where {N} =
    i == j || any(d + j == i || d + i == j for d in ALL_DIRECTIONS)

direction(i::CartesianIndex{N}) where {N} = CartesianIndex(sign.(i.I))


# Parse Input

const DIRECTIONS = cartesian_directions(2)

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
            if !are_adjacent(hi, ti)
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
                if !are_adjacent(tis[j - 1], tis[j])
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
