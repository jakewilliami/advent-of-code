# Input is a string that contains single digits interspersed with other letters, new-line
# delimited.  Each line represents calibration instructions for a weather machine, and we
# are to extract the calibration value from each line.
#
# Part 1 of the problem requires us to extract the calibration value by combining the first
# and last numbers of each string.  Part 2 states that, as well as digits, we have to extract
# the numbers that are spelled out!

parse_input(input_file::String) = readlines(input_file)

extract_digits(s::String) = Int[parse(Int, c) for c in s if isdigit(c)]

extract_number_from_digits(d::Vector{Int}) = 10d[1] + d[end]

function part1(data::Vector{String})
    return sum(extract_number_from_digits(extract_digits(s)) for s in data)
end

function extract_numbers(s::String)
    numbers = String["one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]
    numbers_or = join(numbers, "|")
    numbers_pat = Regex("(\\d|$numbers_or)")
    A = Int[]
    for m in eachmatch(numbers_pat, s; overlap = true)
        match = m.match
        if length(match) == 1 && isdigit(only(match))
            push!(A, parse(Int, only(match)))
        else
            push!(A, findfirst(==(match), numbers))
        end
    end
    return A
end

function part2(data::Vector{String})
    return sum(extract_number_from_digits(extract_numbers(s)) for s in data)
end

function main()
    data = parse_input("data01.txt")

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == 54634
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    @assert part2_solution == 53855
    println("Part 2: $part2_solution")
end

main()
