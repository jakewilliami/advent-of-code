# Description: what was the problem; how did I solve it; and (optionally)
# any thoughts on the problem or how I did.

# ]add https://github.com/jakewilliami/AdventOfCode.jl Statistics LinearAlgebra Combinatorics DataStructures StatsBase IntervalSets OrderedCollections MultidimensionalTools  # TODO: IterTools, ProgressMeter, BenchmarkTools, Memoization
using AdventOfCode.Parsing, AdventOfCode.Multidimensional
using Base.Iterators
using ProgressMeter
using Statistics
using LinearAlgebra
using Combinatorics
using Memoization
using DataStructures
using StatsBase
using IntervalSets
using OrderedCollections
using MultidimensionalTools


### Parse Input ###

const Index = CartesianIndex{2}
const Shape = Set{Index}
const System = Shapes = Vector{Shape}

struct Space
    width::Int
    height::Int
    requirements::Dict{Int, Int}  # system shape index => required count
end

function parse_input(input_file::String)
    # M = readlines_into_char_matrix(input_file)
    S = readchomp(input_file)
    parts = split(S, "\n\n")  # Parsing._lines_into_matrix
    shapes = parts[1:end-1]
    S = Shape[]
    for shape in shapes
        lines = split(shape, "\n")
        popfirst!(lines)
        M = Parsing._lines_into_matrix(lines)
        indices = Set(i - Index(1, 1) for i in CartesianIndices(M) if M[i] == '#')
        push!(S, indices)
    end

    requirements = split(parts[end], "\n")
    R = Space[]
    for requirement in requirements
        w, h, shapes... = Parsing.get_integers(requirement)
        D = Dict{Int, Int}(i => n for (i, n) in enumerate(shapes))
        push!(R, Space(w, h, D))
    end

    return S, R

    # L = strip.(readlines(input_file))
    # L = get_integers.(L)
    return L
end


### Part 1 ###

function apply_shape!(M::BitMatrix, shape::Shape, sᵢ::Index; loose::Bool = false)
    for i in shape
        j = sᵢ + i #- Index(1, 1)
        if !loose
            M[j] = true
        else
            if hasindex(M, j)
                M[j] = true
            end
        end
    end
    return M
end

function rendershape(shape::Shape)
    max_r = maximum(first(i.I) for i in shape) + 1
    max_c = maximum(last(i.I) for i in shape) + 1
    M = fill('.', max_r, max_c)
    for i in shape
        M[i] = '#'
    end
    io = IOBuffer()
    for r in eachrow(M)
        for c in r
            print(io, c)
        end
        println(io)
    end
    return String(take!(io))
    # return join(eachrow(), '\n')
end

function fits(sᵢ::Index, shape::Shape, M::BitMatrix)
    # First, check that all indices would be allowed
    # println(rendershape(shape))
    for i in shape
        j = sᵢ + i #- Index(1, 1)
        # println("  $(sᵢ.I) + $(i.I) - (1, 1) = $(j.I)")
        if !hasindex(M, j)
            # println("HERE")
            return false
        end
    end

    # Then we need to check that no shapes overlap
    M′ = falses(size(M))
    apply_shape!(M′, shape, sᵢ)
    # sum!(M′, M)  # NOTE: this will coerce to bitmatrix, so need to change type # NOTE: actually it doesn't do what I thought
    M′ = Matrix{Int}(M′)
    M′ .+= M
    # println(M′)
    return all(<=(1), M′)
    return !any(>(1), M′)

    for i in shape
        j = i + sᵢ
        c = M[j]
        if !c
            # M[j] =
        end
    end
end

function Base.rotr90(i::Index, sz::NTuple{2, Int})
    error("not implemented")
    n, m = sz
    r, c = Tuple(i)
    return Index(c, n - r + 1)
end

mapsz(f, P::Set{Index}, sz::NTuple{2, Int}) = Set{Index}(f(i, sz) for i in P)
# Base.rotr90(P::Set{Index}, sz::NTuple{2, Int}) = mapsz(rotr90, P, sz)
function Base.rotr90(P::Shape, sz::NTuple{2, Int})
    P = [Tuple(i) for i in P]
    # P = Tuple.(P)
    rows = [r for (r, _) in P]
    cols = [c for (_, c) in P]

    rmin, rmax = minimum(rows), maximum(rows)
    cmin, cmax = minimum(cols), maximum(cols)

    h = rmax - rmin + 1
    w = cmax - cmin + 1

    norm = Set((r - rmin, c - cmin) for (r,c) in P)

    # (r,c) ⟼ (c, h − 1 − r)
    Set(Index(c, h - 1 - r) for (r, c) in norm)
end

function Base.rotl90(i::Index, sz::NTuple{2, Int})
    error("not implemented")
    n, m = sz
    r, c = Tuple(i)
    return Index(m - c + 1, r)
end

# Base.rotl90(P::Set{Index}, sz::NTuple{2, Int}) = mapsz(rotl90, P, sz)
function Base.rotl90(P::Shape, sz::NTuple{2, Int})
    P = [Tuple(i) for i in P]
    # P = Tuple.(P)
    rows = [r for (r, _) in P]
    cols = [c for (_, c) in P]

    rmin, rmax = minimum(rows), maximum(rows)
    cmin, cmax = minimum(cols), maximum(cols)

    h = rmax - rmin + 1
    w = cmax - cmin + 1

    norm = Set((r - rmin, c - cmin) for (r,c) in P)

    # (r,c) ⟼ (w − 1 − c, r)
    Set(Index(w - 1 - c, r) for (r, c) in norm)
end

function mirror_along_vert_axis(i::Index, sz::NTuple{2, Int})  # left-right
    n, m = sz
    r, c = Tuple(i)
    return Index(r, m - c + 1)
end

mirror_along_vert_axis(P::Set{Index}, sz::NTuple{2, Int}) =
    mapsz(mirror_along_vert_axis, P, sz)

function mirror_along_horiz_axis(i::Index, sz::NTuple{2, Int})  # top-bottom
    n, m = sz
    r, c = Tuple(i)
    return Index(n - r + 1, c)
end

mirror_along_horiz_axis(P::Set{Index}, sz::NTuple{2, Int}) =
    mapsz(mirror_along_horiz_axis, P, sz)

function Base.rot180(i::Index, sz::NTuple{2, Int})
    error("not implemented")
    a = rotr90(rotr90(i, sz), sz)
    b = rotl90(rotl90(i, sz), sz)
    c = mirror_along_vert_axis(mirror_along_horiz_axis(i, sz), sz)
    @assert a == b == c
    return a
end

# Base.rot180(P::Set{Index}, sz::NTuple{2, Int}) = mapsz(rot180, P, sz)
Base.rot180(P::Set{Index}, sz::NTuple{2, Int}) = rotl90(rotl90(P, sz), sz)

#=
rot90cw = mirror_diag ∘ mirror_tb
rot90ccw = mirror_diag ∘ mirror_lr
rot180 = mirror_tb ∘ mirror_lr
=#

function shape_permutations(shape::Shape, sz::NTuple{2, Int})
    #=perms = Shape[]
    rotations = (identity, rotl90, rotr90, rot180)
    mirrors = (identity, mirror_along_vert_axis, mirror_along_horiz_axis)
    for rotf in rotations
        for mirrf in mirrors
            shape′ = rotf(mirrf(shape, sz), sz)
            push!(perms, shape′)
        end
    end
    return perms=#

    perms = []

    identity(P::Set{Index}, sz::NTuple{2, Int}) = P
    rotations = (identity, rotl90, rot180, rotr90)

    # rotations only
    for rot in rotations
        push!(perms, rot(shape, sz))
        # push!(perms, (rot(shape, sz), string(rot)))
    end

    # mirror once, then rotate
    mirrored = mirror_along_vert_axis(shape, sz)
    for rot in rotations
        push!(perms, rot(mirrored, sz))
        # push!(perms, (rot(mirrored, sz), "mirror ∘ " * string(rot)))
    end

    return unique(perms)
end

# TODO: can't we use BFS?
@memoize function solve(shapes::Shapes, M::BitMatrix, sofar=[])
    isempty(shapes) && return true, sofar, M
    # shape = popfirst!(shapes)
    already_taken = [i for i in CartesianIndices(M) if M[i] == '#']
    shape = first(shapes)
    for i in CartesianIndices(M)
        for shape′ in shape_permutations(shape, size(M))
            i ∈ already_taken && continue
            f = fits(i, shape′, M)
            println("si = $i, $(length(shapes)), $(string(hash(shapes), base=16)[1:7]), $f")
            if f
                M′ = apply_shape!(copy(M), shape′, i)
                return solve(copy(shapes)[2:end], M′, vcat(sofar, i))
            end
        end
    end
    return false, sofar, M
    error("no solution")
end

# This is the bfs solution
function solve(shapes_::Shapes, M_::BitMatrix, perms)
    Q = Queue{Tuple{Index, Shapes, BitMatrix}}()
    seen = Set{Tuple{Index, Shapes, BitMatrix}}()

    # initialise queue with the possible starting positions of the shapes
    for i in CartesianIndices(M_)
        enqueue!(Q, (i, copy(shapes_), copy(M_)))
    end

    while !isempty(Q)
        i, shapes, M = dequeue!(Q)
        # rend(M) = join((join((c ? '#' : '.') for c in row) for row in eachrow(M)), '\n')
        # println("trying starting position  $i; shapes remaining $(length(shapes))\n$(join(join(c ? '#' : '.' for c in row) for eachrow(M), '\n'))")
        isempty(shapes) && return true#, M

        if (i, shapes, M) ∈ seen
            continue
        end
        push!(seen, (i, shapes, M))

        # take the first shape from the top
        shape = shapes[1]
        # println("trying starting position  $i; shapes remaining $(length(shapes)); fits: $(fits(j, shapes, )); space: \n$(join((join((c ? '#' : '.') for c in row) for row in eachrow(M)), '\n'))\n")

        # for all possible ways to rotate and flip the shape
        # for shape′ in perms
        for shape′ in shape_permutations(shape, size(M))
        # for (shape′, perm) in shape_permutations(shape, size(M))
            # and for all possible places to put the shape
            for j in CartesianIndices(M)
                M[j] && continue
                # already taken in the matrix; not worth pursuing
                # if any(j == k for k in CartesianIndices(M) if M[k] == '#')
                    # continue
                # end
                #=M0 = fill('.', size(M))
                M0[findall(M)] .= '#'
                M1 = copy(M0)
                M0[j] = 'S'
                for k in shape′
                    l = j + k
                    # println("    l = $(Tuple(j)) + $(Tuple(k)) = $(Tuple(l))")
                    if hasindex(M1, l)
                        M1[l] = '*'
                    end
                end=#
                # M1 = apply_shape!(copy(M), shape′, j, loose=true)
                # println("trying starting position  $i; shapes remaining $(length(shapes)); next start $j; next perm \"$perm\", fits: $(fits(j, shape′, M)); space: \n$(join((join((c) for c in row) for row in eachrow(M0)), '\n'))\nafter application:\n$(join((join((c) for c in row) for row in eachrow(M1)), '\n'))\n")

                # println("~~~~trying starting position  $j; shapes remaining $(length(shapes)); space: \n$(join((join((c ? '#' : '.') for c in row) for row in eachrow(M)), '\n'))\n")
                # if the shape fits in the next then apply and try
                # NOTE: Currently I am trying to make it so that the two shapes in the first example fit together, but they don't seem to be coming up with the right starting index - needs to be rotated r 90, and starts at maybe (1, 3)
                # NOTE: IT APPEARS THAT THE CULPRIT IS THAT ROT IS NOT WORKING PROPELY
                if fits(j, shape′, M)
                    M′ = apply_shape!(copy(M), shape′, j)
                    enqueue!(Q, (j, shapes[2:end], M′))
                end
            end
        end
    end

    return false
end

function try_fit_shapes(shapes::Shapes, req::Space)
    # Step 1: make a grid
    M = falses(req.height, req.width)
    # println(M)

    # Step 2: collate required shapes
    S = Shape[]
    # println(req.requirements)
    for (i, n) in req.requirements
        # println("$i => $n, 1:$n = $(length(1:n))")
        for _ in 1:n
            push!(S, shapes[i])
        end
    end

    # println("!!", S)

    # AHH!  I was using "shapes" not "S".  Stupid bug (one of them)
    return solve(S, M)

    # Step 3: try to fit them together??
    for i in CartesianIndices(M)
        M′ = copy(M)
        # Step 3.1: for each index, in the Matrix, try and fit together the
        # pieces required, starting at that index
    end
end

function part1(data)
    shapes, requirements = data
    # req = requirements[3]

    # NOTE: TRYING THE TEST CASES AND THEY ARE FAILING BECAUSE 2ND REQ DOES NOT FIT
    # I FORGOT ROTATIONS AND MIRRORING
    # println(req)
    # try_fit_shapes(shapes, req)

    a = 0
    # NOTE: NOW IT WORKS BUT IT'S MUCH TOO SLOW
    @showprogress for req in requirements
        a += try_fit_shapes(shapes, req)
    end

    a
end


### Part 2 ###

function part2(data)
end


### Main ###

function main()
    data = parse_input("data12.txt")
    data = parse_input("data12.test.txt")
    # println(data)

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
