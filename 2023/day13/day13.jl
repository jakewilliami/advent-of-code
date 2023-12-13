# I got stuck on part 2 for OVER AN HOUR because the algorithm is greedy :(

using AdventOfCode.Parsing, AdventOfCode.Multidimensional

function parse_input(input_file::String)
    L = split(read(input_file, String), "\n\n")
    return Matrix{Char}[Parsing._lines_into_matrix(split(b, "\n")) for b in L]
end

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

    ai = CartesianIndices(ntuple(k -> k == d ? (max(i - max(min(i, size(M, k) - i), 1) + 1, 1):i) : (firstindex(M, k):lastindex(M, k)), Val{N}()))
    bi = CartesianIndices(ntuple(k -> k == d ? ((i + 1):min(i + max(min(i, size(M, k) - i), 1), size(M, k))) : (firstindex(M, k):lastindex(M, k)), Val{N}()))

    a = view(M, ai)
    b = view(M, bi)

    return a == reverse(b, dims=d)
end

function find_reflection(M::Matrix{Char}, not_ri::ReflectiveIndex = invalid_reflective_index)
    nrows, ncols = size(M)

    for i in axes(M, 1)
        i == nrows && continue
        ri = ReflectiveIndex(rows, i)
        is_reflective(M, ri) && ri != not_ri && return ri
    end

    for i in axes(M, 2)
        i == ncols && continue
        ri = ReflectiveIndex(cols, i)
        is_reflective(M, ri) && ri != not_ri && return ri
    end

    return invalid_reflective_index
end

function score_reflection(ri::ReflectiveIndex)
    ri.dim == rows && return 100ri.i
    ri.dim == cols && return ri.i
    return 0
end

function part1(data::Vector{Matrix{Char}})
    res = 0
    for M in data
        ri = find_reflection(M)
        res += score_reflection(ri)
    end
    return res
end

function flip_smudge!(M::Matrix{Char}, i)
    c = M[i]

    if c == '.'
        M[i] = '#'
    elseif c == '#'
        M[i] = '.'
    else
        error("Unhandled char '$c'")
    end

    return M
end

function new_reflection_valid(new_ri::ReflectiveIndex, old_ri::ReflectiveIndex)
    new_ri != invalid_reflective_index || return false
    return new_ri != old_ri
end

function find_new_reflection(M::Matrix{Char})
    ri = find_reflection(M)
    ri0 = ri

    for i in CartesianIndices(M)
        M2 = copy(M)
        flip_smudge!(M2, i)
        ri2 = find_reflection(M2, ri0)
        if new_reflection_valid(ri2, ri0)
            ri = ri2
            break
        else
            i == last(CartesianIndices(M)) && println("WARN: no new reflection found")
        end
    end
    @assert ri != ri0
    return ri
end

function part2(data::Vector{Matrix{Char}})
    res = 0
    for M in data
        ri = find_new_reflection(M)
        res += score_reflection(ri)
    end
    return res
end

function main()
    data = parse_input("data13.txt")
    # data = parse_input("data13.test.txt")

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == 33047
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    @assert part2_solution == 28806
    println("Part 2: $part2_solution")
    # not 37107 too high
end

main()
