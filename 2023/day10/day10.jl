# Reminds me of day 18 from last year (lava)
# TODO: Flood fill
# TODO: to get flood fill working, you will need to increase the resolution:
# https://www.reddit.com/r/adventofcode/comments/18evyu9/comment/kcqgnoy/

# point_in_path
# https://github.com/matplotlib/matplotlib/blob/v3.8.2/lib/matplotlib/path.py#L502
# https://github.com/matplotlib/matplotlib/blob/v3.8.2/src/_path.h#L271
# https://github.com/matplotlib/matplotlib/blob/v3.8.2/src/_path.h#L241
# https://github.com/matplotlib/matplotlib/blob/v3.8.2/src/_path.h#L105


using AdventOfCode.Parsing, AdventOfCode.Multidimensional

parse_input(input_file::String) = readlines_into_char_matrix(input_file)


### Part 1 ###

const Index = CartesianIndex{2}

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

const PIPE_DIRS = Dict{Char, Set{Index}}(
    '|' => Set{Index}((INDEX_ABOVE, INDEX_BELOW)),
    '-' => Set{Index}((INDEX_LEFT, INDEX_RIGHT)),
    'L' => Set{Index}((INDEX_ABOVE, INDEX_RIGHT)),
    'J' => Set{Index}((INDEX_ABOVE, INDEX_LEFT)),
    '7' => Set{Index}((INDEX_BELOW, INDEX_LEFT)),
    'F' => Set{Index}((INDEX_BELOW, INDEX_RIGHT)),
    '.' => Set{Index}(),
)
const DIRS_TO_PIPE = Dict{Set{Index}, Char}(reverse(p) for p in PIPE_DIRS)

get_pipe_directions(c::Char) = PIPE_DIRS[c]
get_pipe_from_directions(ds::Set{Index}) = DIRS_TO_PIPE[ds]

# Infer pipe at starting position based on its surroundings
function infer_pipe(i::Index, data::Matrix{Char})
    A = Index[]
    for d in cardinal_directions(2)
        j = i + d
        hasindex(data, j) || continue
        t = get_pipe_directions(data[j])
        d′ = opposite_direction(d)
        d′ ∈ t && push!(A, d′)
    end

    t = Set{eltype(A)}(A)
    return get_pipe_from_directions(t)
end

# Traverse the pipe system
function walk_pipe_system(i::Index, data::Matrix{Char}; path::Vector{Index} = Index[])
    hasindex(data, i) || return path
    push!(path, i)

    for d in get_pipe_directions(data[i])
        j = i + d
        if j ∉ path
            walk_pipe_system(j, data, path = path)
        end
    end
    return path
end

function get_cycle(data::Matrix{Char})
    data = copy(data)
    si = findfirst(==('S'), data)
    data[si] = infer_pipe(si, data)
    path = walk_pipe_system(si, data)
    return path
end

function part1(data::Matrix{Char})
    path = get_cycle(data)
    return fld(length(path), 2)
end


### Part 2 ###

function part2(data)
    data = copy(data)
    si = findfirst(==('S'), data)
    data[si] = infer_pipe(si, data)
    path = walk_pipe_system(si, data)
    # path = get_cycle(data)

    VERTICAL_SECTIONS = ("FJ", "L7", "|")
    SECTION_BEGINS = "FL"
    SECTION_ENDS = "J7|"

    # parity solution
    # https://github.com/morgoth1145/advent-of-code/blob/35c7163a89f2b3c6d5e25f4eff3da4c72639284e/2023/10/solution.py#L72
    # https://github.com/morgoth1145/advent-of-code/blob/b0b7443ec28abbc4e283cb0aa6cf3726eb9199e9/2023/10/solution.py#L83
    # https://www.reddit.com/r/adventofcode/comments/18evyu9/comment/kcqnzmq/
    # https://www.reddit.com/r/adventofcode/comments/18evyu9/comment/kcqgo61/

    #=
    // Section Ends
    '|' => Set{Index}((INDEX_ABOVE, INDEX_BELOW)),
    'J' => Set{Index}((INDEX_ABOVE, INDEX_LEFT)),
    '7' => Set{Index}((INDEX_BELOW, INDEX_LEFT)),

    // Section Begins
    'F' => Set{Index}((INDEX_BELOW, INDEX_RIGHT)),
    'L' => Set{Index}((INDEX_ABOVE, INDEX_RIGHT)),
    =#

    _SECTION_BEGINS = union(get_pipe_directions.(('F', 'L')))
    _SECTION_ENDS = union(get_pipe_directions.(('J', '7', '|')))

    res, curr_row = 0, 0
    local is_enclosed::Bool, current_section::String

    for (ri, row) in enumerate(eachrow(data))
        is_enclosed = false
        for (ci, c) in enumerate(row)
            if CartesianIndex(ri, ci) ∈ path
                c ∈ "|F7" && (is_enclosed = !is_enclosed)
            else
                res += is_enclosed
            end
        end
    end
    return res

    # Odd parity is enclosed
    # If an odd number of vertical tiles have been seen in any given cell, then any ground tiles are enclosed by pipes.  This is similar to checking if an arbitrary point is enclosed in an arbitrary polygon
    for (ri, row) in enumerate(eachrow(data))
        is_enclosed = false
        current_section = ""

        for (ci, c) in enumerate(row)
            i = CartesianIndex(ri, ci)
            if i ∈ path
                c = data[i]
                ds = get_pipe_directions(c)
                if c ∈ SECTION_BEGINS
                # if all(∈(_SECTION_BEGINS), ds)
                    current_section = string(c)
                elseif c ∈ SECTION_ENDS
                    current_section *= c
                    # if any(!(iszero ∘ last ∘ Tuple), get_pipe_directions(c))
                    if current_section ∈ VERTICAL_SECTIONS
                        is_enclosed = !is_enclosed
                    end
                    current_section = ""
                end
            else
                res += is_enclosed
            end
        end
    end

    return res

    for i in CartesianIndicesRowWise(data)
        this_row = first(i.I)
        if this_row != curr_row
            is_enclosed = false
            current_section = ""
            curr_row = this_row
        end

        if i in path
            c = data[i]
            if c in SECTION_BEGINS
                current_section = string(c)
            elseif c in SECTION_ENDS
                current_section *= c
                if current_section in VERTICAL_SECTIONS
                    is_enclosed = !is_enclosed
                end
                current_section = ""
            end
        else
            res += is_enclosed
        end
    end

    return res

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
    in_points, out_points = Set{Index}(), Set{Index}()

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

function part2a(data)
    data = copy(data)
    si = findfirst(==('S'), data)
    data[si] = infer_pipe(si, data)
    path = walk_pipe_system(si, data)
    # path = get_cycle(data)

    VERTICAL_SECTIONS = ("FJ", "L7", "|")
    SECTION_BEGINS = "FL"
    SECTION_ENDS = "J7|"

    res, curr_row = 0, 0
    local is_enclosed::Bool, current_section::String

    for y in axes(data, 1)
        is_enclosed = false
        current_section = ""
        for x in axes(data, 2)
            i = CartesianIndex(y, x)
            if i in path
                c = data[i]
                if c in SECTION_BEGINS
                    current_section = string(c)
                elseif c in SECTION_ENDS
                    current_section *= c
                    if current_section in VERTICAL_SECTIONS
                        is_enclosed = !is_enclosed
                    end
                    current_section = ""
                end
            else
                res += is_enclosed
            end
        end
    end

    return res
end

function part2b(data)
    data = copy(data)
    si = findfirst(==('S'), data)
    data[si] = infer_pipe(si, data)
    path = walk_pipe_system(si, data)
    # path = get_cycle(data)

    VERTICAL_SECTIONS = ("FJ", "L7", "|")
    SECTION_BEGINS = "FL"
    SECTION_ENDS = "J7|"

    res, curr_row = 0, 0
    local is_enclosed::Bool, current_section::String

    for i in CartesianIndicesRowWise(data)
        this_row = first(i.I)
        if this_row != curr_row
            is_enclosed = false
            current_section = ""
            curr_row = this_row
        end

        if i in path
            c = data[i]
            if c in SECTION_BEGINS
                current_section = string(c)
            elseif c in SECTION_ENDS
                current_section *= c
                if current_section in VERTICAL_SECTIONS
                    is_enclosed = !is_enclosed
                end
                current_section = ""
            end
        else
            res += is_enclosed
        end
    end

    return res
end

function part2c(data)
    data = copy(data)
    si = findfirst(==('S'), data)
    data[si] = infer_pipe(si, data)
    path = walk_pipe_system(si, data)
    # path = get_cycle(data)

    VERTICAL_SECTIONS = ("FJ", "L7", "|")
    SECTION_BEGINS = "FL"
    SECTION_ENDS = "J7|"

    res, curr_row = 0, 0
    local is_enclosed::Bool, current_section::String

    for (ri, row) in enumerate(eachrow(data))
        is_enclosed = false
        current_section = ""

        for (ci, c) in enumerate(row)
            i = CartesianIndex(ri, ci)
            if i in path
                c = data[i]
                if c in SECTION_BEGINS
                    current_section = string(c)
                elseif c in SECTION_ENDS
                    current_section *= c
                    if current_section in VERTICAL_SECTIONS
                        is_enclosed = !is_enclosed
                    end
                    current_section = ""
                end
            else
                res += is_enclosed
            end
        end
    end

    return res
end

function part2d(data)
    data = copy(data)
    si = findfirst(==('S'), data)
    data[si] = infer_pipe(si, data)
    path = walk_pipe_system(si, data)

    res = 0
    local is_enclosed::Bool

    for (ri, row) in enumerate(eachrow(data))
        is_enclosed = false
        for (ci, c) in enumerate(row)
            if CartesianIndex(ri, ci) ∈ path
                c ∈ "|F7" && (is_enclosed = !is_enclosed)
            else
                res += is_enclosed
            end
        end
    end

    return res
end

function part2e(data)
    data = copy(data)
    si = findfirst(==('S'), data)
    data[si] = infer_pipe(si, data)
    path = walk_pipe_system(si, data)

    res = 0
    local is_enclosed::Bool

    for i in CartesianIndicesRowWise(data)
        isone(last(i.I)) && (is_enclosed = false)
        if i ∈ path
            c = data[i]
            # OR `c ∈ "-FL"`
            c ∈ "|F7" && (is_enclosed = !is_enclosed)
        else
            res += is_enclosed
        end
    end

    return res
end

function part2f(data)
    data = copy(data)
    si = findfirst(==('S'), data)
    data[si] = infer_pipe(si, data)
    path = walk_pipe_system(si, data)

    res = 0
    local is_enclosed::Bool

    for i in CartesianIndices(data)
        isone(first(i.I)) && (is_enclosed = false)
        if i ∈ path
            c = data[i]
            # OR `c ∈ "-FL"`
            c ∈ "-7J" && (is_enclosed = !is_enclosed)

        else
            res += is_enclosed
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
    part2_solution = part2e(data)
    println("Part 2: $part2_solution")
    @assert part2_solution == 367
    # not 549 too high
    # not 377 too high
end

main()



using BenchmarkTools

data = parse_input("data10.txt")
@btime part2a($data)
@btime part2b($data)
@btime part2c($data)
@btime part2d($data)
@btime part2e($data)
@btime part2f($data)

#=
  155.576 ms (39192 allocations: 1.82 MiB)
  150.510 ms (39192 allocations: 1.82 MiB)
  162.644 ms (39192 allocations: 1.82 MiB)
  148.151 ms (19 allocations: 729.97 KiB)
  160.134 ms (19 allocations: 729.97 KiB)
  154.555 ms (19 allocations: 729.97 KiB)
=#
