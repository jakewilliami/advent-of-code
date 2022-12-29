# Today was pretty straight forward.  We had to parse a list of "numbers" (SNAFU numbers, a
# made up number system that effectively changed the base of the number, and added some
# extra characters).  Parsing these numbers was easy enough.  Converting decimal numbers to
# SNAFU numbers I found quite a bit more challenging, but I did refine my solution after
# solving it initially, so this function is clean now.
#
# In part 1, we had to sum the SNAFU numbers from our input together, and convert the sum
# back into a SNAFU number.
#
# I have not completed part 2 as part 2 must be completed after all other parts of all other
# days are completed, however, at time of writing, I have 11 parts still to finish.


### Parse input

const SNAFU_CODE_UNITS = Dict{Char, Int}('2' => 2, '1' => 1, '0' => 0, '-' => -1, '=' => -2)
const SNAFU_CODE_UNITS_REVERSE =
    Dict{Int, Char}(2 => '2', 1 => '1', 0 => '0', -1 => '-', -2 => '=')


function snafu2dec(s::String; base::Int = 5)
    m, n = 1, 0
    for d in reverse(s)
        n += SNAFU_CODE_UNITS[d] * m
        m *= base
    end
    return n
end


function parse_input(data_file::String)
    data = Int[]
    for line in eachline(data_file)
        # Instead of using digits four through zero, the digits are 2, 1, 0, minus (written
        # -), and double-minus (written =).  Minus is worth -1, and double-minus is worth -2
        n = snafu2dec(line)
        push!(data, n)
    end
    return data
end


### Part 1

function dec2snafu(n::Int; base::Int = 5)
    io = IOBuffer()
    while n > 0
        c = SNAFU_CODE_UNITS_REVERSE[(n + 2) % base - 2]
        print(io, c)
        n = round(Int, n / base)
    end
    return reverse(String(take!(io)))
end

part1(data::Vector{Int}) = dec2snafu(sum(data))


### Main

function main()
    data = parse_input("data25.txt")

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == "2=-0=01----22-0-1-10"
    println("Part 1: $part1_solution")

    # Part 2
    # part2_solution = part2(data)
    # @assert part2_solution == ""
    # println("Part 2: $part2_solution")
end


main()
