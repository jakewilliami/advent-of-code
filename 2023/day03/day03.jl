# Our input is a grid.  Classic AoC.  The grid consists of numbers, symbols,
# and blank space (represented as periods).
#
# In part 1, we are to extract the numbers that are adjacent to symbols.
#
# In part 2, we need to only count the numbers around the `*' symbols, if and
# only if there are exactly 2 adjacent numbers to it.
#
# I think that I made this quite complicated.  I think my solution is *fine*,
# but I think there are likely easier ways to do this.  I found part 2 easier
# than part 1, given my data format.


using AdventOfCode.Parsing, AdventOfCode.Multidimensional


### Parse Input ###

parse_input(input_file::String) =
    readlines_into_char_matrix(input_file)


### Part 1 ###

function _scan_number_indices(i::CartesianIndex{2}, data::Matrix{Char})
    is = CartesianIndex[i]
    y, x = Tuple(i)
    j = i + INDEX_RIGHT
    while hasindex(data, j) && isdigit(data[j])
        push!(is, j)
        j += INDEX_RIGHT
    end
    j = i + INDEX_LEFT
    while hasindex(data, j) && isdigit(data[j])
        push!(is, j)
        j += INDEX_LEFT
    end
    return sort(is)
end

function _parse_number(io::IOBuffer, data::Matrix{Char}, indices)
    for j in indices
        print(io, data[j])
    end
    s = String(take!(io))
    return parse(Int, s)
end

is_symbol(c::Char) = !isdigit(c) && c != '.'

function adjacent_to_symbol(number_is::Vector{CartesianIndex}, data::Matrix{Char})
    for i in number_is
        for c in cartesian_adjacencies(data, i)
            is_symbol(c) && return true
        end
    end
    return false
end

# See also final state of part 1 before implementing CartesianIndicesRowWise:
#   https://github.com/jakewilliami/advent-of-code/blob/c233f857/2023/day03/day03.jl#L26-L67
# This benchmarks faster than the row-wise solution (as expected).
function part1(data::Matrix{Char})
    res = 0
    int_parse_io = IOBuffer()

    numbers_seen = UInt[]

    # Scan data for symbols and extract adjacent numbers
    for i in CartesianIndices(data)
        c = data[i]
        is_symbol(c) || continue

        # We found a symbol.  Get its surrounding digits
        for (i2, c2) in cartesian_adjacencies_with_indices(data, i)
            if isdigit(c2)
                number_is = _scan_number_indices(i2, data)
                if hash(number_is) ∈ numbers_seen
                    continue
                end
                push!(numbers_seen, hash(number_is))
                res += _parse_number(int_parse_io, data, number_is)
            end
        end
    end

    return res
end


function part1_rowwise(data::Matrix{Char})
    res = 0
    int_parse_io = IOBuffer()

    numbers_seen = UInt[]
    is_to_skip = CartesianIndex[]

    for i in CartesianIndicesRowWise(data)
        # Need to skip the rest of the number
        isempty(is_to_skip) || popfirst!(is_to_skip)
        i ∈ is_to_skip && continue

        # Parse this one if it's a number that's adjacent to a symbol
        c = data[i]
        isdigit(c) || continue

        number_is = _scan_number_indices(i, data)
        num_hash = hash(number_is)

        if adjacent_to_symbol(number_is, data) && num_hash ∉ numbers_seen
            res += _parse_number(int_parse_io, data, number_is)
        end
        append!(is_to_skip,number_is)
    end

    return res
end


### Part 2 ###

function part2(data::Matrix{Char})
    res = 0
    int_parse_io = IOBuffer()

    # Get indices of gears
    gear_is = CartesianIndex[]
    for i in CartesianIndices(data)
        data[i] == '*' && push!(gear_is, i)
    end

    # Get indices of adjactent numbers
    digits_is = Tuple{CartesianIndex{2}, Vector{CartesianIndex}}[]
    for i in gear_is
        digit_is = CartesianIndex[]
        for (j, c) in cartesian_adjacencies_with_indices(data, i)
            isdigit(c) && push!(digit_is, j)
        end
        # Push the gear index, and the list of digit indices around it
        push!(digits_is, (i, digit_is))
    end

    # Extract adjacent numbers around gears
    gear_numbers = Dict{CartesianIndex{2}, Vector{Int}}()
    numbers_seen = UInt[]
    for (gear_i, idx_set) in digits_is
        for i in idx_set
            number_is = _scan_number_indices(i, data)
            if hash(number_is) ∈ numbers_seen
                continue
            end
            push!(numbers_seen, hash(number_is))
            n = _parse_number(int_parse_io, data, number_is)
            gear_numbers[gear_i] = vcat(get(gear_numbers, gear_i, []), [n])
        end
        seen = UInt[]
    end

    # Calculate answer
    for (_k, v) in gear_numbers
        if length(v) == 2
            res += prod(v)
        end
    end
    return res
end


function main()
    data = parse_input("data03.txt")

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == 527144
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    @assert part2_solution == 81463996
    println("Part 2: $part2_solution")
end

main()
