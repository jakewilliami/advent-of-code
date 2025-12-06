# Today, we are given a matrix of integers, but the last row of the matrix
# denotes an operation with which to apply to each column.
#
# In part one, we do simply that: for each column, we apply the operation
# to each element in the column.  This will produce a reduced, single row
# of columns with operations applied.  We sum the results.
#
# Part two was more tricky.  Even though the matrix was made up of distinct
# columns, the spacing around the numbers were arbitrary (i.e., they were not
# left nor right aligned).  It turns out that we needed to read the numbers
# from right to left, top to bottom.  For example, the column
#     12
#     6
# Translates to the vector
#     2
#     16
#
# I misunderstood this part multiple times.  I thought they were talking about
# significant bits (e.g., starting with the ones, then tens, and so on), so I
# implemented that logic multiple times.  Then I reread it and realised they were
# actually talking about the spacing in the puzzle input (which I had stripped
# out).  After I understood the question, my first solution was very messy, but
# got the right answer.  I then spent a much longer time trying to clean up
# the solution, using fewer temporary objects and essentially trying to get
# it all in one pass.  Once I got the row/colum index logic right, this was
# simple, and quite efficient.
#
# Similar to yesterday, I wouldn't call the problem hard, neccessarily.  It is
# just not an algorithm I've ever had to write, so it took a good amount of thinking
# to get it functional.  Overall, a pretty fun day.


### Parse Input ###

const Operation = Function  # Union{typeof(+), typeof(*)}
const OPS = Dict{Char, Operation}('+' => +, '*' => *)

function parse_input(input_file::String)
    L = readlines(input_file)

    # Operators are at the bottom of the array
    A = Operation[OPS[only(x)] for x in split(last(L))]

    # Now we parse the main matrix
    nr, nc = length(L) - 1, length(A)
    M = Matrix{Int}(undef, nr, nc)

    for rowᵢ in 1:nr
        row = split(L[rowᵢ])
        for colᵢ in 1:nc
            M[rowᵢ, colᵢ] = parse(Int, row[colᵢ])
        end
    end

    # Return the interpretted matrix, column-wise operators, and raw lines
    return M, A, L
end


### Part 1 ###

function apply_ops_across_cols(M::Matrix{Int}, ops::Vector{Operation})
    @assert size(M, 2) == length(ops)

    return sum(enumerate(eachcol(M))) do (i, col)
        reduce(ops[i], col)
    end
end

function part1(data)
    M, ops, _ = data
    return apply_ops_across_cols(M, ops)
end


### Part 2 ###

const IDENTITIES = Dict{Operation, Int}((+) => 0, (*) => 1)

# Because we apply column-wise operations, we need the multiplicative or addititive
# identity along each column, respective of the operations that are going to be made.
# This means that if a number is blank and isn't filled in, the default value doesn't
# mess with the maths when we go to compute the final result.
function identity_matrix(similar_mat::Matrix{Int}, col_ops::Vector{Operation})
    M = similar(similar_mat)
    for colᵢ in 1:size(M, 2)
        op = col_ops[colᵢ]
        n = IDENTITIES[op]
        M[:, colᵢ] = fill(n, size(M, 1))
    end
    return M
end

# "Cephalopod math is written right-to-left in columns. Each number is given in its
# own column, with the most significant digit at the top and the least significant
# digit at the bottom. (Problems are still separated with a column consisting only
# of spaces, and the symbol at the bottom of the problem is still the operator to
# use.)"
#
# This means that the following matrix:
#     123  328   51  64
#      45  64   387  23
#       6  98   215  314
#
# Is instead written as:
#     356    8  175    4
#      24  248  581  431
#       1  369   32  623
#
# Note the column-wise re-interpretation of each column.  The Cephalopods are very
# peculiar when it comes to maths!
function reinterpret_with_cephalopod_math(
    M₀::Matrix{Int},
    ops::Vector{Operation},
    lines::Vector{String},
)
    # Exclude operators from raw data
    pop!(lines)

    # Instantiate output matrix and temp buffer
    M = identity_matrix(M₀, ops)
    io = IOBuffer()

    # Starting from the left-most position in each line, construct numbers vertically
    # for each row, ignoring spaces.
    colᵢ, rowᵢ = size(M, 2), 1
    for sᵢ in length(first(lines)):-1:1
        # Construct number from the sᵢᵗʰ column of the input
        for line in lines
            c = line[sᵢ]
            !isspace(c) && print(io, c)
        end

        # Extract the number from buffer and parse it as an integer
        #
        # NOTE: if the string is empty then we've just tried passing a blank
        # column separator, which is necessarily just spaces.  If so, we need
        # to shift the column index by one, as we have finished with this
        # column.
        #
        # I tried for a long time just skipping this condition, and doing the
        # column shift later:
        #     colᵢ -= iszero(mod(rowᵢ, size(M, 1)))
        #
        # But this didn't work for some reason.
        s = String(take!(io))
        if isempty(s)
            colᵢ -= 1
            continue
        end

        n = parse(Int, s)

        # Set parsed number from this column in the matrix
        M[rowᵢ, colᵢ] = n

        # Increment row index
        rowᵢ = mod1(rowᵢ + 1, size(M, 1))
    end

    return M
end

function part2(data)
    M₀, ops, lines = deepcopy(data)
    M = reinterpret_with_cephalopod_math(M₀, ops, lines)
    return apply_ops_across_cols(M, ops)
end


### Main ###

function main()
    data = parse_input("data06.txt")

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == 4693419406682
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    @assert part2_solution == 9029931401920
    println("Part 2: $part2_solution")
end

main()
