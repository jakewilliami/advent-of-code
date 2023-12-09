# Today's problem was super simple.  Each line of the input consisted of the
# starting line of a table.  The next row of the table is the differences
# between each element.  For example:
#   0   3   6   9  12  15
#     3   3   3   3   3
#       0   0   0   0
#
# From this, we can extrapolate values in the top row to the right or left
# by starting from the bottom and working backwards.
#
# For any given pair (a, b), you can calculate the next row's corresponding
# value by calculating b - a (= c).
#   a   b
#     c
#
# Simple algebra tells us that b can be calculated by a + c, and a by b - c.
#
# Part 1 asks us to extrapolate the value of b for the top row.  Part 2 asks
# us to calculate backwards the value of a for the top row.  The naive solution
# to this wwas straight forward and efficient enough.
#
# I know there will be a nice maths-y solution to this (maybe polynomial
# generator functions or something crazy), but this is brute-forceable.

const Row{T} = Vector{T}
const Table{T} = Vector{Row{T}}

parse_input(input_file::String) = Row{Int}[parse.(Int, split(l)) for l in readlines(input_file)]


### Part 1 ###

# c = b - a
calc_new_row(row::Row{T}) where {T <: Number} = T[row[i] - row[i - 1] for i in 2:length(row)]

function fill_table(row::Row{T}) where {T <: Number}
    table = [row]
    while !all(iszero, row)
        row = calc_new_row(row)
        push!(table, row)
    end
    return table
end

function extrapolate_table(table::Table{T}) where {T <: Number}
    table = deepcopy(table)
    push!(table[end], 0)
    for i in (length(table) - 1):-1:1
        # b = a + c
        push!(table[i], table[i][end] + table[i + 1][end])
    end
    return table
end

function first_extrapolation(row::Row{T}) where {T <: Number}
    full_table = fill_table(row)
    extrapolated = extrapolate_table(full_table)
    return last(first(extrapolated))
end

part1(data::Table{Int}) = sum(first_extrapolation(row) for row in data)


### Part 2 ###

function extrapolate_table_backwards(table::Table{T}) where {T <: Number}
    table = deepcopy(table)
    pushfirst!(table[end], 0)
    for i in (length(table) - 1):-1:1
        # a = b - c
        pushfirst!(table[i], table[i][1] - table[i + 1][1])
    end
    return table
end

function first_back_extrapolation(row::Row{T}) where {T <: Number}
    full_table = fill_table(row)
    extrapolated = extrapolate_table_backwards(full_table)
    return first(first(extrapolated))
end

part2(data::Table{Int}) = sum(first_back_extrapolation(row) for row in data)


### Main ###

function main()
    data = parse_input("data09.txt")

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == 1987402313
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    @assert part2_solution == 900
    println("Part 2: $part2_solution")
end

main()
