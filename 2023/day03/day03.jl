using AdventOfCode.Parsing, AdventOfCode.Multidimensional

parse_input(input_file::String) =
    readlines_into_char_matrix(input_file)

function _parse_number(io::IOBuffer, data::Matrix{Char}, indices)
    for j in indices
        print(io, data[j])
    end
    s = String(take!(io))
    return parse(Int, s)
end

function part1(data)
    res = 0
    int_parse_io = IOBuffer()

    for (row_i, _row) in enumerate(eachrow(data))
        i = CartesianIndex(row_i, 1)
        while hasindex(data, i)
            c = data[i]
            if isdigit(c)
                is = CartesianIndex[i]
                j = i + INDEX_RIGHT

                # Collect indices that make up the number
                while true
                    j = i + INDEX_RIGHT
                    i = j
                    if hasindex(data, j) && isdigit(data[j])
                        push!(is, j)
                    else
                        next_row = true
                        break
                    end
                end

                # Check if number adjacent to symbol
                adj_to_symbol = false
                for i2 in is
                    for c2 in cartesian_adjacencies(data, i2)
                        if !isdigit(c2) && c2 != '.'
                            adj_to_symbol = true
                            @goto end_adj_symbol
                        end
                    end
                end
                @label end_adj_symbol

                # Parse number
                if adj_to_symbol
                    res += _parse_number(int_parse_io, data, is)
                end
            end
            i += INDEX_RIGHT
            hasindex(data, i) || @goto next_row
        end
        @label next_row
    end
    return res
end


function _scan_number_indices(i::CartesianIndex{2}, data::Matrix{Char})
    is = CartesianIndex[i]
    y, x = Tuple(i)
    j = i
    while true
        j += INDEX_RIGHT
        if hasindex(data, j) && isdigit(data[j])
            push!(is, j)
        else
            break
        end
    end
    j = i
    while true
        j += INDEX_LEFT
        if hasindex(data, j) && isdigit(data[j])
            push!(is, j)
        else
            break
        end
    end
    return sort(is)
end

function part2(data)
    res = 0
    int_parse_io = IOBuffer()

    # Get indices of gears
    gear_is = CartesianIndex[]
    for i in CartesianIndices(data)
        data[i] == '*' && push!(gear_is, i)
    end

    # Get indices of adjactent numbers
    digits_is = []
    for i in gear_is
        digit_is = []
        for (j, c) in cartesian_adjacencies_with_indices(data, i)
            isdigit(c) && push!(digit_is, j)
        end
        push!(digits_is, (i, digit_is))
    end

    # Extract adjacent numbers
    gear_numbers = Dict()
    seen = []
    for (gear_i, idx_set) in digits_is
        for i in idx_set
            number_is = _scan_number_indices(i, data)
            if hash(number_is) in seen
                continue
            end
            push!(seen, hash(number_is))
            n = _parse_number(int_parse_io, data, number_is)
            gear_numbers[gear_i] = vcat(get(gear_numbers, gear_i, []), [n])
        end
        seen = []
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
