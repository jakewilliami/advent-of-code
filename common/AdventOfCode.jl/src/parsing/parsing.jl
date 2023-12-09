module Parsing

export get_integers
export readlines_into_char_matrix, readlines_into_int_matrix


# Integers

# Will return a list of pairs integers and their respective index ranges within the string.
function _get_integers_with_ranges(s::S) where {S <: AbstractString}
    integers = Pair{Int, UnitRange{Int}}[]
    i, iₑ = firstindex(s), lastindex(s)

    while true
        # Get a range of digit integers from i of length j
        j = 0
        while (i + j) <= iₑ && isdigit(s[i + j])
            j = nextind(s, j)
        end

        # If j is not zero, we have found a valid integer; let's parse it the way we parse
        # any base 10 number
        if !iszero(j)
            m, n = 1, 0

            # Can increment substring index by one here, as all digits are a single codeunit
            for k in j:-1:1
                n += (s[i + k - 1] - '0') * m
                m *= 10
            end

            push!(integers, n => i:(i + j - 1))
        end

        # Break from the loop if we are now past the end of the string
        if (i + j) > iₑ
            break
        end

        i = nextind(s, i + j)
    end

    return integers
end


function _get_integers(s::S) where {S <: AbstractString}
    integers = _get_integers_with_ranges(s)
    return Int[i for (i, _) in integers]
end


# Characters preceeding a number that may indicate said number is negative
# https://www.wikiwand.com/en/Plus_and_minus_signs#Character_codes
# hyphen, minus, en dash, small hyphen, full width hyphen, em dash
const _MINUS_CHARS = ('-', '−', '–', '﹣', '－', '—')


function _get_integers_with_negatives(s::S) where {S <: AbstractString}
    iₛ = firstindex(s)
    integers = _get_integers_with_ranges(s)
    integers_with_negatives = Vector{Int}(undef, length(integers))
    for (i, (m, r)) in enumerate(integers)
        rₛ = first(r)
        # Number cannot be negative if it starts at the start of the string; otherwise, we
        # check if the previous character to the start of the substring is a negative sign
        is_negative = rₛ == iₛ ? false : s[prevind(s, rₛ)] ∈ _MINUS_CHARS
        integers_with_negatives[i] = is_negative ? -m : m
    end
    return integers_with_negatives
end


"""
```julia
get_integers(s::String; negatives::Bool = false) -> Vector{Int}
```

Get all integers (optionally, potential negatives) from a given string.

Suprisingly useful in parsing many AoC probelms if you don't want to use regular expressions.

For example:
```julia
julia> get_integers("Sensor at x=3938443, y=-271482: closest beacon is at x=4081274, y=1177185"; negatives = true)
4-element Vector{Int64}:
 3938443
 -271482
 4081274
 1177185
```
"""
get_integers(s::S; negatives::Bool = false) where {S <: AbstractString} = (negatives ? _get_integers_with_negatives : _get_integers)(s)


# Matrices

_lines_into_matrix(lines, f::Function = identity) =
    reduce(vcat, permutedims(f.(collect(s))) for s in lines if !isempty(strip(s)))


"""
```julia
readlines_into_char_matrix(file::String) -> Matrix{Char}
```

Create a matrix of characters given a file, in which each line represents a row, and each character, a respective element in that row.

For example, given the file
```
abcde
fghij
```

This function will produce the matrix
```julia
2×5 Matrix{Char}:
 'a'  'b'  'c'  'd'  'e'
 'f'  'g'  'h'  'i'  'j'
```

See also: [`readlines_into_int_matrix`](@ref).
"""
readlines_into_char_matrix(file::String) = _lines_into_matrix(eachline(file))


"""
```julia
readlines_into_char_matrix(file::String) -> Matrix{Int}
```

Create a matrix of integers (one per character) given a file, in which the line index represents the row, and the character index, the column.

For example, given the file
```
01234
56789
```

This function will produce the matrix
```julia
2×5 Matrix{Int64}:
 0  1  2  3  4
 5  6  7  8  9
```

See also: [`readlines_into_char_matrix`](@ref).
"""
readlines_into_int_matrix(file::String) =
    _lines_into_matrix(eachline(file), c -> parse(Int, c))

end  # end module
