# The data were a grid of characters.  Empty space denoted by a dot.  An alphanumeric
# character represented a "frequency."  The idea was to look for lines running through
# all combinations of frequencies and find "antinodes" on those lines.
#
# In part one, the antinodes could only form on those lines at a point where one
# frequency was double the distance from the point as the other frequency.  In part
# two, there was no such requirement.
#
# This was a bad day for me.  I was travelling so I couldn't do the problem immediately,
# and then I misunderstood the problem a couple of times, as I found the wording really
# confusing.  Then, I had a myriad of problems... copy error from hard coding vectors
# in my distance function; not getting the line to extrapolate past its defining points;
# only checking cardinal directions to define the line; and, critically, failing to
# account for antennae overlapping with frequencies---only noticed thanks to this:
# <https://www.reddit.com/r/adventofcode/comments/1h9cz19/comment/m0zx3fi>
#
# Other than all of that trouble, today was really quite simple.  It's as shrimple
# as that.


using AdventOfCode.Parsing, AdventOfCode.Multidimensional
using Distances


### Parse Input ###

parse_input(input_file::String) = readlines_into_char_matrix(input_file)


### Part 1 ###

isfrequency(c) = isuppercase(c) || islowercase(c) || c ∈ '0':'9'

antennae_indices(data) = findall(isfrequency, data)

function points_on_line(x::CartesianIndex{2}, y::CartesianIndex{2}, data::Matrix{T}) where {T}
    y0, x0 = Tuple(x)
    y1, x1 = Tuple(y)
    nrows, ncols = size(data)
    points = Set()

    dx = x1 - x0
    dy = y1 - y0

    if abs(dx) > abs(dy)
        # Line is more horizontal
        for x in 1:ncols
            t = (x - x0) / dx
            y = y0 + t * dy
            if 1 ≤ y ≤ nrows
                if isinteger(y)
                    push!(points, CartesianIndex(round(Int, y), x))
                end
            end
        end
    else
        # Line is more vertical
        for y in 1:nrows
            t = (y - y0) / dy
            x = x0 + t * dx
            if 1 ≤ x ≤ ncols
                if isinteger(x)
                    push!(points, CartesianIndex(y, round(Int, x)))
                end
            end
        end
    end

    return points
end

function acceptable_distance(
    antenna_i::CartesianIndex{N},
    freq_i::CartesianIndex{N},
    freq_j::CartesianIndex{N},
) where {N}
    # Using Distances.jl because I can't be bothered
    dist(i, j) = Euclidean()(i.I, j.I)
    dᵢ, dⱼ = dist(antenna_i, freq_i), dist(antenna_i, freq_j)
    return dᵢ ≈ 2dⱼ || dⱼ ≈ 2dᵢ
end

function solve(data::Matrix{Char}; predicate::Function = (_...) -> true)
    AN = Set{CartesianIndex{2}}()
    A = antennae_indices(data)

    for i in 1:length(A)
        ai = A[i]
        for j in (i+1):length(A)
            aj = A[j]
            data[ai] == data[aj] || continue
            for k in points_on_line(ai, aj, data)
                predicate(k, ai, aj) && push!(AN, k)
            end
        end
    end

    return length(AN)
end

part1(data::Matrix{Char}) = solve(data, predicate = acceptable_distance)


### Part 2 ###

part2(data::Matrix{Char}) = solve(data)


### Main ###

function main()
    data = parse_input("data08.txt")

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == 390
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    @assert part2_solution == 1246
    println("Part 2: $part2_solution")
end

main()
