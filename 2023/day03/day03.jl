using AdventOfCode.Parsing, AdventOfCode.Multidimensional

function parse_input(input_file::String)
    return readlines_into_char_matrix(input_file)
    return read(input_file, String)
    A = readlines(input_file)
    return A
end

function parse_number(is, data)
    io = IOBuffer()
    for j in is
        print(io, data[j])
    end
    s = String(take!(io))
    return parse(Int, s)
end

function part1(data)
    res = 0

    for (row_i, _row) in enumerate(eachrow(data))
        i = CartesianIndex(row_i, 1)
        while hasindex(data, i)
            c = data[i]
            if isdigit(c)
                is = CartesianIndex[i]
                j = i + CartesianIndex(0, 1)

                # Collect indices that make up the number
                while true
                    j = i + CartesianIndex(0, 1)
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
                    for d in cartesian_directions(2)
                        j = i2 + d
                        if hasindex(data, j) && !isdigit(data[j]) && data[j] != '.'
                            adj_to_symbol = true
                            @goto end_adj_symbol
                        end
                    end
                end
                @label end_adj_symbol

                # Parse number
                if adj_to_symbol
                    res += parse_number(is, data)
                end
            end
            i += CartesianIndex(0, 1)
            hasindex(data, i) || @goto next_row
        end
        @label next_row
    end
    return res
end


function extract_number_is(i, data)
    is = [i]
    y, x = Tuple(i)
    r = 1
    while true
        j = i + CartesianIndex(0, r)
        # println(j)
        if hasindex(data, j) && isdigit(data[j])
            push!(is, j)
            r += 1
        else
            break
        end
    end
    l = 1
    while true
        # j = CartesianIndex(y, x - l)
        j = i - CartesianIndex(0, l)
        if hasindex(data, j) && isdigit(data[j])
            push!(is, j)
            l += 1
        else
            break
        end
    end
    return sort(is)
end

function part2(data)
    res = 0

    # Get indices of gears
    gear_is = CartesianIndex[]
    for i in CartesianIndices(data)
        data[i] == '*' && push!(gear_is, i)
    end
    # println("gears: ", gear_is)

    # Get indices of adjactent numbers
    digits_is = []
    for i in gear_is
        digit_is = []
        for d in cartesian_directions(2)
            j = i + d
            if hasindex(data, j) && isdigit(data[j])
                push!(digit_is, j)
            end
        end
        push!(digits_is, (i, digit_is))
    end
    # println("adj-digits: ", digits_is)

    # Extract adjacent numbers
    gear_numbers = Dict()
    seen = []
    for (gear_i, idx_set) in digits_is
        for i in idx_set
            number_is = extract_number_is(i, data)
            if hash(number_is) in seen
                continue
            end
            push!(seen, hash(number_is))
            n = parse_number(number_is, data)
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





   #=idx_itr = CartesianIndices(data)
    i, istate = iterate(idx_itr)
    while i !== nothing
        println("istate (i): $istate ($i)")
        c = data[i]
        if isdigit(c)
            println("here")
            is = CartesianIndex[i]
            j = i + CartesianIndex(0, 1)

            # Collect indices that make up the number
            while hasindex(data, j) && isdigit(data[j])
                push!(is, j)
                i = iterate(idx_itr, istate)
                println("i: $i, j: $j")
                if i !== nothing
                    i, istate = i
                    j = i + CartesianIndex(0, 1)
                    println("j: $j")
                end
            end
            println(is)

            # Check if number adjacent to symbol
            adj_to_symbol = false
            for i2 in is
                for d in cartesian_directions(2)
                    j = i2 + d
                    if hasindex(data, j) && !isdigit(data[j]) && data[j] != '.'
                        adj_to_symbol = true
                    end
                end
            end

            # Parse number
            if adj_to_symbol
                io = IOBuffer()
                for j in is
                    print(io, data[j])
                end
                s = String(take!(io))
                println(s)
                res += parse(Int, s)
            end
        end
        i = iterate(idx_itr, istate)
        if i !== nothing
            i, istate = i
        end
    end=#
    #=for i in CartesianIndices(data)
        c = data[i]
        if isdigit(c)
            for d in cartesian_directions(2)
                j = i + d
                if hasindex(data, j)
                    c2 = data[j]
                    if !isdigit(c2) && c2 != '.'
                        res += parse(Int, c)
                    end
                end
            end
        end
    end=#
