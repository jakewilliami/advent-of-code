using AdventOfCode.Parsing, AdventOfCode.Multidimensional
# using Base.Iterators
# using Statistics
# using LinearAlgebra
# using Combinatorics
using DataStructures
# using StatsBase
# using IntervalSets
# using OrderedCollections

const Index = CartesianIndex{2}

function parse_input(input_file::String)
    # M = readlines_into_char_matrix(input_file)
    # S = strip(read(input_file, String))
    L = strip.(readlines(input_file))
    # L = get_integers.(L)
    return L
end

# KP = Union{Int, Char, Nothing}[7 8 9; 4 5 6; 1 2 3; nothing 0 'A']
KP = Union{Char, Nothing}['7' '8' '9'; '4' '5' '6'; '1' '2' '3'; nothing '0' 'A']
DP = Union{Char, Nothing}[nothing '^' 'A'; '<' 'v' '>']
SI = CartesianIndex{2}(size(KP))  # bottom right
SDI = CartesianIndex{2}(1, size(DP, 2))  # top right
NAI = CartesianIndex{2}(size(KP, 1), 1)  # bottom left
NADI = CartesianIndex{2}(1, 1)  # top left

function write_key_directions(target, pos, disallowed)
    write_directions(target, KP, pos, disallowed)
end

function write_dir_directions(target, pos, disallowed)
    write_directions(target, DP, pos, disallowed)
end

function write_line(io::IOBuffer, n, d)
    !isnothing(d) && print(io, repeat(d, n))
end

function write_horiz_first(io::IOBuffer, nh, nv, hd, vd)
    write_line(io, nh, hd)
    write_line(io, nv, vd)
    String(take!(io))
end

function path_horiz_first(pos::CartesianIndex{2}, nh, nv, xdir, ydir)
    P = CartesianIndex{2}[pos]
    while nh > 0
        pos += xdir
        push!(P, pos)
        nh -= 1
    end
    while nv > 0
        pos += ydir
        push!(P, pos)
        nv -= 1
    end
    # @assert pos == target
    return P
end

function write_vert_first(io::IOBuffer, nh, nv, hd, vd)
    write_line(io, nv, vd)
    write_line(io, nh, hd)
    String(take!(io))
end

function path_vert_first(pos::CartesianIndex{2}, nh, nv, xdir, ydir)
    P = CartesianIndex{2}[pos]
    while nv > 0
        pos += ydir
        push!(P, pos)
        nv -= 1
    end
    while nh > 0
        pos += xdir
        push!(P, pos)
        nh -= 1
    end
    # @assert pos == target
    return P
end

function write_alternating(io::IOBuffer, nh, nv, hd, vd)
    while nv > 0 || nh > 0
        # println(num_vert, ", ", num_horiz)
        if nv > 0
            print(io, vd)
            nv -= 1
        end

        if nh > 0
            print(io, hd)
            nh -= 1
        end
    end
    String(take!(io))
end

function path_alternating(pos::CartesianIndex{2}, nh, nv, xdir, ydir)
    P = CartesianIndex{2}[pos]
    while nv > 0 || nh > 0
        if nv > 0
            pos += ydir
            push!(P, pos)
            nv -= 1
        end

        if nh > 0
            pos += xdir
            push!(P, pos)
            nh -= 1
        end
    end
    # @assert pos == target
    return P
end

function write_directions(target::Char, M, pos, disallowed)
    i = nothing
    for j in CartesianIndices(M)
        if M[j] == target
            i = j
            break
        end
    end
    @assert !isnothing(i)
    δ = pos - i
    y, x = Tuple(δ)
    # println(δ)
    num_vert = abs(y)
    vert_dir = nothing
    ydir = origin(2)
    sign_vert = sign(y)
    if !iszero(sign_vert)
        if sign_vert == -1
            vert_dir = 'v'  # down
            ydir = INDEX_DOWN
        elseif sign_vert == 1
            vert_dir = '^'  # up
            ydir = INDEX_UP
        else
            error("unreachable")
        end
    end

    num_horiz = abs(x)
    horiz_dir = nothing
    xdir = origin(2)
    sign_horiz = sign(x)
    if !iszero(sign_horiz)
        if sign_horiz == -1
            horiz_dir = '>'  # right
            xdir = INDEX_RIGHT
        elseif sign_horiz == 1
            horiz_dir = '<'  # left
            xdir = INDEX_LEFT
        else
            error("unreachable")
        end
    end

    io = IOBuffer()

    # if I switch the order of these blocks, the answer changes...
    # i need to ensure that the path does not go to the bad position; i should rewrite this to use bfs
    # println(disallowed)
    S = String[]
    P1 = path_horiz_first(pos, num_horiz, num_vert, xdir, ydir)
    println(write_horiz_first(io, num_horiz, num_vert, horiz_dir, vert_dir), " (allowed: $(disallowed ∉ P1)): ", P1)
    if disallowed ∉ P1
        push!(S, write_horiz_first(io, num_horiz, num_vert, horiz_dir, vert_dir))
    end
    if disallowed ∉ path_vert_first(pos, num_horiz, num_vert, xdir, ydir)
        push!(S, write_vert_first(io, num_horiz, num_vert, horiz_dir, vert_dir))
    end
    if disallowed ∉ path_alternating(pos, num_horiz, num_vert, xdir, ydir)
        push!(S, write_alternating(io, num_horiz, num_vert, horiz_dir, vert_dir))
    end
    @assert !isempty(S)
    S′ = length.(S)
    # println(S)
    # println(S′)
    # println(findmin(S′))
    # _, k = findmin(S′)
    # s = k == 0 ? "" : S[k]
    # return S[first(findmin(S′))], i
    return S[last(findmin(S′))], i

    return String(take!(io)), i
end

DIRS = Dict(
    INDEX_RIGHT => '>',
    INDEX_LEFT => '<',
    INDEX_UP => '^',
    INDEX_DOWN => 'v',
)

function write_directions_bfs(target::Char, M, pos::Index)
    target_i = nothing
    for j in CartesianIndices(M)
        if M[j] == target
            target_i = j
            break
        end
    end
    @assert !isnothing(target_i)
    best_score = Inf
    best_path = ""
    best_end = origin(2)
    Q = Queue{Tuple{String, Vector{Index}, Index, Int}}()
    S = Set{Tuple{Vector{Index}, Index}}()
    enqueue!(Q, ("", Index[pos], pos, 0))
    while !isempty(Q)
        s, p, i, n = dequeue!(Q)

        if i == target_i
            return s, i
            if n < best_score
                best_score = n
                best_path = s
                best_end = i
                # return s, i
            end
        end

        (p, i) ∈ S && continue
        push!(S, (p, i))

        for d in cardinal_directions(2)
            j = i + d
            hasindex(M, j) || continue
            isnothing(M[j]) && continue
            s′ = "$s$(DIRS[d])"
            enqueue!(Q, (s′, vcat(p, j), j, n + 1))
        end
    end

    @assert !isempty(best_path)
    @assert best_end != origin(2)
    best_path, best_end
end

function write_directions(seq::AbstractString, M, pos, disallowed)
    io = IOBuffer()
    i = pos
    for c in seq
        s, i = write_directions_bfs(c, M, i)
        print(io, s)
        # s, i = write_directions('A', M, i)
        # print(io, 'A')
        # i = SDI
        # print(io, s)
        print(io, 'A')
    end
    return String(take!(io)), i
end

function write_directions_bfs_all(target::String, M, pos::Index)
    function ffc(M, c)
        for j in CartesianIndices(M)
            M[j] == target && return j
        end
    end

    targets = Index[]
    for c in target
        i = ffc(M, c)
        @assert !isnothing(i)
        push!(targets, i)
    end

    function targets_in_path(targets, path)
        all(i ∈ path for i in targets) || return false
        t = findfirst(==(first(targets)), path)
        @assert !isnothing(t)
        for i in targets[2:end]
            t′ = findfirst(==(i), path)
            t′ > t || return false
            t = t′
        end
        return true
    end

    Q = Queue{Tuple{String, Vector{Index}, Index}}()
    S = Set{Tuple{Vector{Index}, Index}}()
    enqueue!(Q, ("", Index[pos], pos))
    while !isempty(Q)
        s, p, i, n = dequeue!(Q)

        if targets_in_path(targets, p)
            return s, i
        end

        (p, i) ∈ S && continue
        push!(S, (p, i))

        for d in cardinal_directions(2)
            j = i + d
            hasindex(M, j) || continue
            isnothing(M[j]) && continue
            s′ = "$s$(DIRS[d])"
            enqueue!(Q, (s′, vcat(p, j), j, n + 1))
        end
    end
end

function write_key_directions_bfs_all(target, pos)
    write_directions_bfs_all(target, KP, pos)
end

function write_dir_directions_bfs_all(target, pos)
    write_directions_bfs_all(target, DP, pos)
end

mutable struct State
    keypad_pos::Index
    dir1_pos::Index
    dir2_pos::Index
    disallowed_k::Index
    disallowed_d::Index
end

State() = State(SI, SDI, SDI, NAI, NADI)

function solve(state::State, target)
    println(target)
    s, i = write_key_directions_bfs_all(target, state.keypad_pos, state.disallowed_k)
    println(s)
    state.keypad_pos = i
    s, i = write_dir_directions_bfs_all(s, state.dir1_pos, state.disallowed_d)
    println(s)
    state.dir1_pos = i
    s, i = write_dir_directions_bfs_all(s, state.dir2_pos, state.disallowed_d)
    println(s)
    state.dir2_pos = i
    return s
end

function extract_numeric(target)
    parse(Int, only(match(r"(\d+)", target).captures))
end

function complexity(state::State, target)
    s = length(solve(state, target))
    println("target=$target, solution length=$(s), numeric=$(extract_numeric(target)), ans=$(s*extract_numeric(target))")
    s * extract_numeric(target)
end

function offset(d::AbstractString)
    i = origin(2)
    for c in d
        c == 'A' && continue
        if c == '>'
            i += INDEX_RIGHT
        elseif c == '<'
            i += INDEX_LEFT
        elseif c == 'v'
            i += INDEX_DOWN
        elseif c == '^'
            i += INDEX_UP
        else
            error("unreachable")
        end
    end
    i
end

function are_equiv(d1::AbstractString, d2::AbstractString)
    count(==('A'), d1) == count(==('A'), d2) || (println("$(count(==('A'), d1)) vs $(count(==('A'), d2))");return false)
    println("d1 ($d1) = $(offset(d1)) ($(length(d1))), d2 $(d2) = $(offset(d2)) ($(length(d2)))")
    offset(d1) == offset(d2)
end

function part1(data)
    state = State()
    # solve(state, "029A")
    # solve(state, "379A")
    complexity(state, "179A")
    println(are_equiv("<v<A>>^A<vA<A>>^AAvAA<^A>A<v<A>>^AAvA^A<vA>^AA<A>A<v<A>A>^AAAvA<^A>A", "AAvA<^A>AAvA^A<vA>^AA<A>A<<vA>A>^AAAvA<^A>A"))
    println(are_equiv("<v<A>>^A<vA<A>>^AAvAA<^A>A<v<A>>^AAvA^A<vA>^AA<A>A<v<A>A>^AAAvA<^A>A", "<v<A>A<A>^>AvA<^A>A<vA<A>^>AvA<^Av>A^A<v<A>^>AAvA^A<vA^>AA<A>A<v<A>A^>AAA<Av>A^A"))
    # THIS IS WRONG: length I have is 68 but there's a path that's solvable in 64
    # complexity(state, "379A")
    # return sum(data) do target
        # complexity(state, target)
    # end
    # println("==========================================")
    # expected, ans
    # println(are_equiv("<A^A>^^AvvvA", "<A^A^^>AvvvA"))
    # println(are_equiv("v<<A>>^A<A>AvA<^AA>A<vAAA>^A", "v<<A^>>A<A>A<AAv>A^Av<AAA^>A"))
    # println(are_equiv("<vA<AA>>^AvAA<^A>A<v<A>>^AvA^A<vA>^A<v<A>^A>AAvA^A<v<A>A>^AAAvA<^A>A", "v<A<AA^>>A<Av>AA^Av<<A^>>AvA^Av<<A^>>AAv<A>A^A<A>Av<A<A^>>AAA<Av>A^A"))
    # println(are_equiv("<v<A>>^AvA^A<vA<AA>>^AAvA<^A>AAvA^A<vA>^AA<A>A<v<A>A>^AAAvA<^A>A", "v<<A^>>AvA^Av<<A^>>AAv<A<A^>>AA<Av>AA^Av<A^>AA<A>Av<A<A^>>AAA<Av>A^A"))
    return 0
end

function part2(data)
end

function main()
    data = parse_input("data21.txt")
    data = parse_input("data21.test.txt")

    # Part 1
    part1_solution = part1(data)
    # @assert part1_solution ==
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    # @assert part2_solution ==
    println("Part 2: $part2_solution")
end

main()
