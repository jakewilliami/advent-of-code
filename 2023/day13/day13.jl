# The puzzle input today is a list of character matrices containing dots and
# octothorps.  Each of the matrices contain an index at the row or column at
# which the matrix is reflective.
#
# Part 1 asked us to find the reflective index for each matrix.  It was simple,
# and I took a relatively short amount of time (though the splitting of matrices
# in the `is_reflective' function was difficult and took some debugging).
#
# Part 2 was also straight forward, but I got stuck on it.  That's because my
# `find_reflection' algorithm was greedy, and I was struggling to find a distinct
# reflective index after flipping a bit in the matrix.  The thing is, flipping a
# bit doesn't necessarily invalidate the previous reflective index, so it might
# still find a distinct one.  That took over an hour to debug...

using AdventOfCode.Parsing, AdventOfCode.Multidimensional

function parse_input(input_file::String)
    L = split(read(input_file, String), "\n\n")
    return Matrix{Char}[Parsing._lines_into_matrix(split(b, "\n")) for b in L]
end


### Part 1 ###

@enum MatrixDimension begin
    invalid = 0
    rows = 1
    cols = 2
end

struct ReflectiveIndex
    dim::MatrixDimension
    i::Int
end

const invalid_reflective_index = ReflectiveIndex(invalid, 0)

# This function is dynamic with the axis of the reflective index.
# For a version of this function separate for rows/columns, see 1327fea.
function is_reflective(M::AbstractArray{<:Any,N}, ri::ReflectiveIndex) where {N}
    i, d = ri.i, Int(ri.dim)

    # Construct indices to select two views of the matrix split by the reflextive
    # index along dimension d.  The view of each side must be symmetrical in size.
    ai = CartesianIndices(ntuple(k -> k == d ? ((i - min(i, size(M, k) - i) + 1):i) : (firstindex(M, k):lastindex(M, k)), Val{N}()))
    bi = CartesianIndices(ntuple(k -> k == d ? ((i + 1):min(i + min(i, size(M, k) - i), size(M, k))) : (firstindex(M, k):lastindex(M, k)), Val{N}()))

    return view(M, ai) == reverse(view(M, bi), dims=d)
end

# Find the reflective index in an m × n matrix by iterating each axis of each dimension.
# This is a greedy algorithm, so there is also an option to exclude an index from the
# search, in the interest of part 2 of today's problem.
function find_reflection(M::Matrix{Char}, not_ri::ReflectiveIndex = invalid_reflective_index)
    for k in 1:ndims(M), i in axes(M, k)
        i == size(M, k) && continue
        ri = ReflectiveIndex(MatrixDimension(k), i)
        is_reflective(M, ri) && ri != not_ri && return ri
    end

    return invalid_reflective_index
end

# Each reflective index is given a score
function score_reflection(ri::ReflectiveIndex)
    ri.dim == rows && return 100ri.i
    ri.dim == cols && return ri.i
    error("Unhandled reflective dimension $(ri.dim)")
end

# Sum scores of each reflective index for part 1
function part1(data::Vector{Matrix{Char}})
    res = 0
    for M in data
        ri = find_reflection(M)
        res += score_reflection(ri)
    end
    return res
end


### Part 2 ###

# Flip the character at position `i' of the matrix
function flip_smudge!(M::Matrix{Char}, i)
    M[i] == '.' && (M[i] = '#')
    M[i] == '#' && (M[i] = '.')
    M[i] ∈ ".#" || error("Unhandled char '$(M[i])'")
    return M
end

# Find a distinct reflective index after flipping one character
function find_new_reflection(M::Matrix{Char})
    ri = ri0 = find_reflection(M)

    for i in eachindex(M)
        M′ = flip_smudge!(copy(M), i)
        ri1 = find_reflection(M′, ri0)
        if ri1 ∉ (ri0, invalid_reflective_index)
            ri = ri1
            break
        end
    end

    @assert ri != ri0
    return ri
end

# Sum scores of alternative reflective indices for part 2
function part2(data::Vector{Matrix{Char}})
    res = 0
    for M in data
        ri = find_new_reflection(M)
        res += score_reflection(ri)
    end
    return res
end


### Main ###

function main()
    data = parse_input("data13.txt")

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == 33047
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    @assert part2_solution == 28806
    println("Part 2: $part2_solution")
end

main()
