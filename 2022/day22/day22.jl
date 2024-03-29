using AdventOfCode.Multidimensional

f, CN = "data22.txt", 50
f, CN = "test.txt", 4

# instructions = []
inst_re = r"([?:\d+RL])"

#=for i in eachmatch(inst_re, instructions_str)
    # n, r = i.captures
    # n = parse(Int, n)
    # r = only(r)
    i = only(i.captures)
    n = tryparse(Int, i)
    if isnothing(n)
        push!(instructions, only(i))
    else
        push!(instructions, n)
    end
end=#

function parse_input(f)
    data, instructions_str = split(readchomp(f), "\n\n")
    data = split(data, '\n')

    instructions = []
    i = 1
    while i <= length(instructions_str)
        s = ""
        while i <= length(instructions_str) && isdigit(instructions_str[i])
            s *= instructions_str[i]
            i += 1
        end
        push!(instructions, parse(Int, s))
        if i <= length(instructions_str)
            push!(instructions, instructions_str[i])
        end
        i += 1
    end

    cols = maximum(length(line) for line in data)
    # M = Matrix{Union{Char, Nothing}}(undef, length(data), cols)
    M = fill(nothing, length(data), cols)
    M = Matrix{Union{Char, Nothing}}(M)
    for (row_i, line) in enumerate(data)
        for (col_i, c) in enumerate(line)
            if c != ' '
                M[row_i, col_i] = c
            end
        end
    end

    return instructions, M
end
instructions, M = parse_input(f)

# println(instructions)
# map(i -> println(repr(length(i))), data)
# println(M)
# map(println, eachcol(M))

function change_direction(dir::CartesianIndex{2}, c::Char)
    #=directions = cardinal_directions(2)
    i = findfirst(==(dir), directions)=#
    directions = Dict{CartesianIndex{2}, CartesianIndex{2}}(
        CartesianIndex(0, -1) => CartesianIndex(-1, 0),
        CartesianIndex(-1, 0) => CartesianIndex(0, 1),
        CartesianIndex(0, 1) => CartesianIndex(1, 0),
        CartesianIndex(1, 0) => CartesianIndex(0, -1),
    )
    directions′ = Dict{CartesianIndex{2}, CartesianIndex{2}}(v => k for (k, v) in directions)
    if c == 'R'
        # j = mod1(i - 1, length(directions))
        dir = directions[dir]
    elseif c == 'L'
        # j = mod1(i + 1, length(directions))
        dir = directions′[dir]
    else
        error("unreachable: $(repr(c))")
    end
    # return directions[j]
    return dir
end

function move_within_bounds(i::CartesianIndex{N}, dir::CartesianIndex{N}, M::Array{T, N}) where {T, N}
     return CartesianIndex(map(mod1, Tuple(i + dir), size(M)))
end

function next_idx(i::CartesianIndex{N}, dir::CartesianIndex{N}, M::Array{Union{Nothing, T}, N}) where {T, N}
    i = move_within_bounds(i, dir, M)
    while isnothing(M[i])
        i = move_within_bounds(i, dir, M)
    end
    return i
end

function dir_score(dir::CartesianIndex{2})
    # scores = reverse(circshift(cardinal_directions(2), 0))
    # score = findfirst(==(dir), scores) - 1
    # @assert !isnothing(score)
    # return score
    scores = Dict{CartesianIndex{2}, Int}(
        CartesianIndex(0, 1) => 0,
        CartesianIndex(1, 0) => 1,
        CartesianIndex(0, -1) => 2,
        CartesianIndex(-1, 0) => 3,
    )
    return scores[dir]
end

function main(instructions, M)
    dir = CartesianIndex(0, 1)  # start going right
    i = next_idx(CartesianIndex(1, 1), dir, M)
    # println("start_pos: $i, start_dir: $dir")
    for inst in instructions
        # println("    moving $(repr(inst))")
        if inst isa Char
            dir = change_direction(dir, inst)
            # println("New direction: $dir")
        elseif inst isa Int
            for _ in 1:inst
                i′ = next_idx(i, dir, M)
                if M[i′] == '#'
                    break
                else
                    @assert M[i] == '.'
                    i = i′
                end
            end
            # println("New pos: $i")
        else
            error("unreachable: $(typeof(inst))")
        end
    end

    # println("$i, $dir, $(dir_score(dir))")
    return sum(map(*, Tuple(i), (1000, 4))) + dir_score(dir)
end

println(main(instructions, M))
#=for r in eachrow(M)
    for c in r
        print(isnothing(c) ? ' ' : c)
    end
    println()
end=#

# 162118 TOO HIGH
# 73346


const RIGHT = CartesianIndex(0, 1)
const DOWN = CartesianIndex(1, 0)
const LEFT = CartesianIndex(0, -1)
const UP = CartesianIndex(-1, 0)

const CubicFaceDirectionPair = Tuple{Int, CartesianIndex{2}}

#     -----
#     | 1 |
# -------------
# | 2 | 3 | 4 |
# -------------
#     | 5 |
#     -----
#     | 6 |
#     -----
const CUBIC_PROJECTION_OFFSETS_OLD_OLD = Dict{CubicFaceDirectionPair, CubicFaceDirectionPair}(
    # A (1)
    (1, RIGHT) => (4, DOWN),
    (1, DOWN) => (3, DOWN),
    (1, LEFT) => (2, DOWN),
    (1, UP) => (6, UP),

    # B (2)
    (2, RIGHT) => (3, RIGHT),
    (2, DOWN) => (5, RIGHT),
    (2, LEFT) => (6, RIGHT),
    (2, UP) => (1, RIGHT),

    # C (3)
    (3, RIGHT) => (4, RIGHT),
    (3, DOWN) => (5, DOWN),
    (3, LEFT) => (2, LEFT),
    (3, UP) => (1, UP),

    # D (4)
    (4, RIGHT) => (6, LEFT),
    (4, DOWN) => (5, LEFT),
    (4, LEFT) => (3, LEFT),
    (4, UP) => (1, LEFT),

    # E (5)
    (5, RIGHT) => (4, UP),
    (5, DOWN) => (6, DOWN),
    (5, LEFT) => (2, UP),
    (5, UP) => (3, UP),

    # F (6)
    (6, RIGHT) => (4, LEFT),
    (6, DOWN) => (1, DOWN),
    (6, LEFT) => (2, RIGHT),
    (6, UP) => (5, UP),
)

#         -----
#         | 1 |
# -------------
# | 2 | 3 | 4 |
# -----------------
#         | 5 | 6 |
#         ---------
const CUBIC_PROJECTION_OFFSETS_OLD = Dict{CubicFaceDirectionPair, CubicFaceDirectionPair}(
    # A (1)
    (1, RIGHT) => (6, LEFT),
    (1, DOWN) => (4, DOWN),
    (1, LEFT) => (3, DOWN),
    (1, UP) => (2, DOWN),

    # B (2)
    (2, RIGHT) => (3, RIGHT),
    (2, DOWN) => (5, UP),
    (2, LEFT) => (6, UP),
    (2, UP) => (1, DOWN),

    # C (3)
    (3, RIGHT) => (4, RIGHT),
    (3, DOWN) => (5, RIGHT),
    (3, LEFT) => (2, LEFT),
    (3, UP) => (1, RIGHT),

    # D (4)
    (4, RIGHT) => (6, DOWN),
    (4, DOWN) => (5, DOWN),
    (4, LEFT) => (3, LEFT),
    (4, UP) => (1, UP),

    # E (5)
    (5, RIGHT) => (6, RIGHT),
    (5, DOWN) => (2, UP),
    (5, LEFT) => (3, UP),
    (5, UP) => (4, UP),

    # F (6)
    (6, RIGHT) => (1, LEFT),
    (6, DOWN) => (2, RIGHT),
    (6, LEFT) => (5, LEFT),
    (6, UP) => (4, LEFT),
)

#     ---------
#     | 1 | 2 |
#     ---------
#     | 3 |
# ---------
# | 4 | 5 |
# ---------
# | 6 |
# -----
const CUBIC_PROJECTION_OFFSETS = Dict{CubicFaceDirectionPair, CubicFaceDirectionPair}(
    # A (1)
    (1, RIGHT) => (2, RIGHT),
    (1, DOWN) => (3, DOWN),
    (1, LEFT) => (4, RIGHT),
    (1, UP) => (6, RIGHT),

    # B (2)
    (2, RIGHT) => (5, LEFT),
    (2, DOWN) => (3, LEFT),
    (2, LEFT) => (1, LEFT),
    (2, UP) => (6, UP),

    # C (3)
    (3, RIGHT) => (2, UP),
    (3, DOWN) => (5, DOWN),
    (3, LEFT) => (4, DOWN),
    (3, UP) => (1, UP),

    # D (4)
    (4, RIGHT) => (5, RIGHT),
    (4, DOWN) => (6, DOWN),
    (4, LEFT) => (1, RIGHT),
    (4, UP) => (3, RIGHT),

    # E (5)
    (5, RIGHT) => (2, LEFT),
    (5, DOWN) => (6, LEFT),
    (5, LEFT) => (4, LEFT),
    (5, UP) => (3, UP),

    # F (6)
    (6, RIGHT) => (5, UP),
    (6, DOWN) => (2, DOWN),
    (6, LEFT) => (1, DOWN),
    (6, UP) => (4, UP),
)


# 2D projection of the faces of a cube
#
#     -----
#     | 1 |
# -------------
# | 2 | 3 | 4 |
# -------------
#     | 5 |
#     -----
#     | 6 |
#     -----
#
# Alt:
#         -----
#         | 1 |
# -------------
# | 2 | 3 | 4 |
# -----------------
#         | 5 | 6 |
#         ---------
#
# Alt alt:
#     ---------
#     | 1 | 2 |
#     ---------
#     | 3 |
# ---------
# | 4 | 5 |
# ---------
# | 6 |
# -----
struct CubicProjection{T}
    data::Vector{Matrix{T}}

    function CubicProjection{T}(data::Vector{Matrix{T}}) where {T}
        @assert length(data) == n_faces(3) "Number of sides ($(length(data))) != number of faces of hypercube in 3 dimensions ($(n_faces(2)))"
        @assert all(size(data[1]) == size(face) for face in view(data, 2:length(data))) "All sides of a cube must have the same size"
        return new{T}(data)
    end
    CubicProjection(data::Vector{Matrix{T}}) where {T} = CubicProjection{T}(data)
end

todo!() = error("not yet implemented")
todo!(s) = error("not yet implemented: $s")

function Base.size(A::CubicProjection{T}) where {T}
    sz = size(first(A.data), 1)
    return (sz, sz, sz)
end

function Base.size(A::CubicProjection{T}, _dim::Int) where {T}
    return Base.heads(size(A))  # Cubes have the same size on every edge
end

struct CubicIndex
    face::Int
    I::CartesianIndex{2}
end

# Base.getindex(A::CubicProjection{T}, faceᵢ::Int, i::Int) where {T} = A[faceᵢ][i]
# Base.getindex(A::CubicProjection{T}, faceᵢ::Int, I::Vararg{Int, N}) where {T, N} = A[faceᵢ][I]
# Base.getindex(A::CubicProjection{T}, faceᵢ::Int, I::CartesianIndex{2}) where {T, N} = A[faceᵢ][I]

# function Base.mod1(i::CubicIndex, M::CubicProjection{T})
function next_idx(i::CubicIndex, dir::CartesianIndex{2}, M::CubicProjection{T}) where {T}
    # dir = CartesianIndex(map(sign, Tuple(j - i.I)))
    @assert all(j ∈ (0, 1) for j in map(abs, Tuple(dir))) "Direction vector must have no magnitude"
    @assert !all(isone, map(abs, Tuple(dir))) "next_idx not currently supported for diagonal directions"
    k = i.I + dir
    # k′ = k

    # If the new index exists in the current face, then we don't have to do anything fancy
    # println("$k => $(hasindex(M.data[i.face], k))")
    hasindex(M.data[i.face], k) && return CubicIndex(i.face, k), dir

    # Otherwise, we have to figure out where the next index is on the new face
    new_face, new_dir = CUBIC_PROJECTION_OFFSETS[(i.face, dir)]
    if new_dir == RIGHT
        # Then col should be 1 (starting from left, moving right)
        k = CartesianIndex(map(*, Tuple(i.I), (1, 0))) + CartesianIndex(0, 1)
    elseif new_dir == DOWN
        # Then row should be 1 (starting from top, moving down)
        k = CartesianIndex(map(*, Tuple(i.I), (0, 1))) + CartesianIndex(1, 0)
    elseif new_dir == LEFT
        # Then col should be end (starting from right, moving left)
        k = CartesianIndex(map(*, Tuple(i.I), (1, 0))) + CartesianIndex(0, size(M, 1)...)
    elseif new_dir == UP
        # Then row should be end (starting from bot, moving up)
        k = CartesianIndex(map(*, Tuple(i.I), (0, 1))) + CartesianIndex(size(M, 1)..., 0)
    else
        error("unreachable: $(new_dir)")
    end

    # println("    orig i: $(i.I) \n    new k: $k ($new_face, $new_dir) \n    (old f: $(i.face), old k: $k′, orig dir: $dir) \n    (size: $(size(M)))")

    return CubicIndex(new_face, k), new_dir  #new_dir)
end

#=function Base.:(+)(i::CubicIndex, j::CartesianIndex{2})
    dir = CartesianIndex(map(sign, Tuple(j - i.I)))
    k = i.I + j
    new_dir = CUBIC_PROJECTION_OFFSETS[(i.face, dir)]
    return CubicIndex(new_face, k)#new_dir)
end

function Base.mod1(i::CubicIndex, sz::Tuple{Int, Int})
end=#

function Base.getindex(A::CubicProjection{T}, i::CubicIndex) where {T}
    face = A.data[i.face]
    hasindex(face, i.I) && return face[i.I]
    todo!(i)
end


# Base.setindex!(A::CubicProjection{T}, v::T, i::Int) where {T. N} = todo!()
# Base.setindex!(A::CubicProjection{T}, v::T, I::Vararg{Int, N}) where {T. N} = todo!()

# Base.IndexStyle(::Type{CubicProjection{T}}) where {T} = todo!()
# Base.getindex(A::CubicProjection{T}, I...) where {T} = todo!()
# setindex!(A::CubicProjection{T}, X, I...) where {T} = todo!()
# iterate(A::CubicProjection{T}) where {T} = todo!()
# length(A::CubicProjection{T}) where {T} = sum(prod.(size.(A)))

# move_index(faceᵢ::Int, i::CartesianIndex{2})

#=function CubicProjection{T}(sides::Vector{Matrix{T}}) where {T}
    @assert length(sides) == n_faces(3) "Number of sides ($(length(sides))) != number of faces of hypercube in 3 dimensions ($(n_faces(2)))"

end=#

function make_cubic_projection(M::Matrix{Union{T, Nothing}}) where {T}
    sz = CN
    sides = Matrix{Union{T, Nothing}}[]
    for i in 1:sz:size(M, 1)
        slice = reduce(vcat, permutedims(filter(!isnothing, row)) for row in eachrow(M[i:(i + sz - 1), :]))
        for i in 1:sz:size(slice, 2)
            push!(sides, slice[:, i:(i + sz - 1)])
        end
    end

    @assert length(sides) == n_faces(3) "Number of sides ($(length(sides))) != number of faces of hypercube in 3 dimensions ($(n_faces(2)))"
    return CubicProjection(sides)
end

function main2(instructions, M)
    M = make_cubic_projection(M)

    dir = CartesianIndex(0, 1)  # start going right
    i = CubicIndex(1, CartesianIndex(1, 1))
    println("start_pos: $i, start_dir: $dir")
    for inst in instructions
        println("    moving $(repr(inst))")
        if inst isa Char
            println("New direction: $dir")
            dir = change_direction(dir, inst)
        elseif inst isa Int
            for _ in 1:inst
                i′, dir′ = next_idx(i, dir, M)
                if M[i′] == '#'
                    break
                else
                    @assert M[i′] == '.'
                    i = i′
                end
            end
            println("New pos: $i")
        else
            error("unreachable: $(typeof(inst))")
        end
    end
    println("$i, $dir")
    return sum(map(*, Tuple(i.I), (1000, 4))) + i.face
end

println(main2(instructions, M))

# NOT

# M = make_cubic_project(M)
# i = CubicIndex(4, )


# 11077
# 44146  # too low
