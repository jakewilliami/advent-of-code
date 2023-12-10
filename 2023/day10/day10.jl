# Reminds me of day 18 from last year (lava)

using AdventOfCode.Parsing, AdventOfCode.Multidimensional
# using Base.Iterators
# using Statistics
# using LinearAlgebra
# using Combinatorics
using DataStructures
# using StatsBase
# using IntervalSets
# using OrderedCollections

function parse_input(input_file::String)
    return readlines_into_char_matrix(input_file)
    L = readlines(input_file)
    return L
end

#=
    | is a vertical pipe connecting north and south.
    - is a horizontal pipe connecting east and west.
    L is a 90-degree bend connecting north and east.
    J is a 90-degree bend connecting north and west.
    7 is a 90-degree bend connecting south and west.
    F is a 90-degree bend connecting south and east.
    . is ground; there is no pipe in this tile.
    S is the starting position of the animal; there is a pipe on this tile, but your sketch doesn't show what shape the pipe has.
=#

# const INDEX_LEFT         = CartesianIndex(0, -1)
# const INDEX_RIGHT        = CartesianIndex(0, 1)
# const INDEX_ABOVE        = CartesianIndex(1, 0)
# const INDEX_BELOW        = CartesianIndex(-1, 0)
# const INDEX_TOP_LEFT     = INDEX_ABOVE + INDEX_LEFT
# const INDEX_TOP_RIGHT    = INDEX_ABOVE + INDEX_RIGHT
# const INDEX_BOTTOM_LEFT  = INDEX_BELOW + INDEX_LEFT
# const INDEX_BOTTOM_RIGHT = INDEX_BELOW + INDEX_RIGHT

function g(t)
    M = Dict(
         Set((INDEX_ABOVE, INDEX_BELOW)) => '|',
         Set((INDEX_LEFT, INDEX_RIGHT)) => '-',
         Set((INDEX_ABOVE, INDEX_RIGHT)) => 'L',
         Set((INDEX_ABOVE, INDEX_LEFT)) => 'J',
         Set((INDEX_BELOW, INDEX_LEFT)) => '7',
         Set((INDEX_BELOW, INDEX_RIGHT)) => 'F',
    )
    return M[t]
end

function f(c)
    M = Dict(
        '|' => Set((INDEX_ABOVE, INDEX_BELOW)),
        '-' => Set((INDEX_LEFT, INDEX_RIGHT)),
        'L' => Set((INDEX_ABOVE, INDEX_RIGHT)),
        'J' => Set((INDEX_ABOVE, INDEX_LEFT)),
        '7' => Set((INDEX_BELOW, INDEX_LEFT)),
        'F' => Set((INDEX_BELOW, INDEX_RIGHT)),
        '.' => Set(),
        # 'S' => ,
    )
    return M[c]
end

function infer_pipe(i, data)
    A = []
    function h!(i, d1, d2, data, A)
        hasindex(data, i + d1) || return
        t = f(data[i + d1])
        d2 in t && push!(A, d2)
    end
    h!(i, INDEX_ABOVE, INDEX_BELOW, data, A)
    h!(i, INDEX_BELOW, INDEX_ABOVE, data, A)
    h!(i, INDEX_LEFT, INDEX_RIGHT, data, A)
    h!(i, INDEX_RIGHT, INDEX_LEFT, data, A)

    t = Set(A)
    return g(t)
end

function walk!(i, data, path)
    hasindex(data, i) || return path
    ds = f(data[i])
    # println("$(data[i]) ($i) => $ds")
    for d in ds
        j = i + d
        # println("!!! [$i] ", j)
        if !(j in path)
            push!(path, j)
            walk!(j, data, path)
        end
    end
    return path
end

function get_cycle(data)
    data = copy(data)
    si = findfirst(==('S'), data)
    data[si] = infer_pipe(si, data)
    path = [si]
    walk!(si, data, path)
    return path
end

function part1(data)
    path = get_cycle(data)
    return fld(length(path), 2)
end

# TODO: Flood fill
# TODO: to get flood fill working, you will need to increase the resolution:
# https://www.reddit.com/r/adventofcode/comments/18evyu9/comment/kcqgnoy/
function is_internal!(
    i::CartesianIndex{2},
    points::Vector{CartesianIndex{2}},
    data,
    in_points::Set{CartesianIndex{2}} = Set{CartesianIndex{2}}(),
    out_points::Set{CartesianIndex{2}} = Set{CartesianIndex{2}}(),
)
    # If the result has been memoised, return immediately
    i ∈ in_points && return true
    i ∈ out_points && return false

    # Otherwise, we need to start looking at each adjacent point
    seen_points = Set{CartesianIndex{2}}()
    Q = Queue{CartesianIndex{2}}()
    enqueue!(Q, i)

    while !isempty(Q)
        j = dequeue!(Q)

        # Skip this index if:
        #   - It is part of the structure;
        #   - We have already processed it; or
        #   - It's a pipe.
        j ∈ points && continue
        j ∈ seen_points && continue
        hasindex(data, j) || continue
        data[j] == '.' || continue
        push!(seen_points, j)

        # TODO: if the current point is part of the cycle, or it is out of bounds

        for d in cardinal_directions(2)
            enqueue!(Q, j + d)
        end
    end

    for p in seen_points
        push!(in_points, p)
    end

    return true
end


# https://github.com/matplotlib/matplotlib/blob/v3.8.2/lib/matplotlib/path.py#L502
# https://github.com/matplotlib/matplotlib/blob/v3.8.2/src/_path.h#L271
# https://github.com/matplotlib/matplotlib/blob/v3.8.2/src/_path.h#L241
# https://github.com/matplotlib/matplotlib/blob/v3.8.2/src/_path.h#L105
# radius r = 0
# result[0] != 0
function points_in_path(points, path)
    results = zeros(Bool, length(points))
    length(path) < 3 && return false
end

#=
function is_inside_cycle(matrix, cycle_indices, start_index)
    rows, cols = size(matrix)
    visited = falses(rows, cols)
    stack = [(start_index[1], start_index[2])]

    while !isempty(stack)
        row, col = pop!(stack)
        visited[row, col] = true

        # Check if the current index is in the cycle
        if (row, col) in cycle_indices
            return true
        end

        # Check neighbors
        for (dr, dc) in [(0, 1), (1, 0), (0, -1), (-1, 0)]
            new_row, new_col = row + dr, col + dc
            if 1 <= new_row <= rows && 1 <= new_col <= cols && !visited[new_row, new_col]
                push!(stack, (new_row, new_col))
            end
        end
    end

    return false
end

# Example usage:
matrix = [
    1 2 3;
    4 5 6;
    7 8 9
]

cycle_indices = [(1, 1), (1, 2), (2, 2), (2, 1)]  # Example cycle indices
start_index = (1, 1)  # Example start index

result = is_inside_cycle(matrix, cycle_indices, start_index)
println(result)
=#
function f(si, path, data)
    visited = falses(size(data))
    S = Stack{CartesianIndex{2}}()
    push!(S, si)

    while !isempty(S)
        i = pop!(S)
        visited[i] = true

        i ∈ path && return true
        for j in adjacent_cardinal_indices(data, i)
            push!(S, j)
        end
    end

    return false
end


function part2(data)
    data = copy(data)
    si = findfirst(==('S'), data)
    data[si] = infer_pipe(si, data)
    path = [si]
    walk!(si, data, path)
    # path = get_cycle(data)

    VERTICAL_SECTIONS = ("FJ", "L7", "|")
    SECTION_BEGINS = "FL"
    SECTION_ENDS = "J7|"

    # parity solution
    # https://github.com/morgoth1145/advent-of-code/blob/35c7163a89f2b3c6d5e25f4eff3da4c72639284e/2023/10/solution.py#L72
    # https://www.reddit.com/r/adventofcode/comments/18evyu9/comment/kcqnzmq/
    #=
    answer = 0

    # Count enclosed tiles by tracking parity per row.
    # If an odd number of vertical tiles have been seen then any ground tiles
    # are enclosed, otherwise they are outside. This is similar to checking
    # if an arbitrary point is enclosed n an arbitrary polygon.
    for y in range(grid.height):
        is_enclosed = False
        current_section = ''
        for x in range(grid.width):
            if (x,y) in loop:
                c = grid[x,y]
                if c in SECTION_BEGINS:
                    current_section = c
                elif c in SECTION_ENDS:
                    current_section += c
                    if current_section in VERTICAL_SECTIONS:
                        is_enclosed = not is_enclosed
                    current_section = ''
            else:
                if is_enclosed:
                    answer += 1

        assert(not is_enclosed)
    =#
    res = 0

    for y in axes(data, 1)
        is_enclosed = false
        current_section = ""
        for x in axes(data, 2)
            i = CartesianIndex(y, x)
            if i in path
                c = data[i]
                if c in SECTION_BEGINS
                    current_section = c
                elseif c in SECTION_ENDS
                    current_section *= c
                    if current_section in VERTICAL_SECTIONS
                        is_enclosed = !is_enclosed
                    end
                    current_section = ""
                end
            else
                if is_enclosed
                    res += 1
                end
            end
        end
    end
    return res



    # Memoise internal and external points to reduce computation time
    in_points, out_points = Set{CartesianIndex{2}}(), Set{CartesianIndex{2}}()

    # DFS: start at first .
    i = findfirst(==('.'), data)
    res = 0
    for i in CartesianIndices(data)
        # Only dots can be in or out of the loop
        c = data[i]
        c == '.' || continue
        res += f(i, path, data)
    end
    return res


    return f(i, path, data)

    return

    res = 0
    for i in CartesianIndices(data)
        # Only dots can be in or out of the loop
        c = data[i]
        c == '.' || continue

        # Any point in the path cannot be a non-pipe
        @assert i ∉ path

        # Count a space if it is within the loop
        # flood fill?
        if is_internal!(i, path, data, in_points, out_points)
            res += 1
        end
    end

    return res
end

function main()
    data = parse_input("data10.txt")
    # data = parse_input("data10.test.txt")
    # data = parse_input("data10.test2.txt")
    # data = parse_input("data10.test3.txt")
    # println(data)

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == 6897
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    @assert part2_solution == 367
    println("Part 2: $part2_solution")
    # not 549 too high
    # not 377 too high
end

main()
