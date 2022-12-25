const SNAFU_CODE_UNITS = Dict{Char, Int}('2' => 2, '1' => 1, '0' => 0, '-' => -1, '=' => -2)
const SNAFU_CODE_UNITS_REVERSE =
    Dict{Int, Char}(2 => '2', 1 => '1', 0 => '0', -1 => '-', -2 => '=')


#=SNAFU_CODE_UNITS_ALT = Dict{Int, Char}(
    0 => -,
    1 => 1,
    2 => 2,
    3 => 10,
    4 => 11,
    5 => 20,
    6 => 21,
    7 => 22,
    8 => =,
    9 => -1,
)=#

function snafu2dec(s::String; base::Int = 5)
    m, n = 1, 0
    for d in reverse(s)
        n += SNAFU_CODE_UNITS[d] * m
        m *= base
    end
    return n
end


#=function snafu2dec(s::String)
    base = 5
    A = []
    m, n = 1, 0
    for d in reverse(s)
        n += SNAFU_CODE_UNITS[d] * m
        push!(A, SNAFU_CODE_UNITS[d] * m)
        m *= base
    end
    return A
end=#

#=D = Dict(
        1 =>  "            1",
        2 =>  "            2",
        3 =>  "           1=",
        4 =>  "           1-",
        5 =>  "           10",
        6 =>  "           11",
        7 =>  "           12",
        8 =>  "           2=",
        9 =>  "           2-",
       10 =>  "           20",
       15 =>  "          1=0",
       20 =>  "          1-0",
     2022 =>  "       1=11-2",
    12345 =>  "      1-0---0",
314159265 =>  "1121-1110-1=0",
)

for (d, s) in D
    @assert parse_snafu(String(strip(s))) == d
end=#


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

#=function snafu_to_decimal(snafu::AbstractString)
    n = 0
    for (i, c) in enumerate(snafu)
        if c == '0'
            n += 0 * 5^(length(snafu) - i - 1)
        elseif c == '1'
            n += 1 * 5^(length(snafu) - i - 1)
        elseif c == '2'
            n += 2 * 5^(length(snafu) - i - 1)
        elseif c == '-'
            n += -1 * 5^(length(snafu) - i - 1)
        elseif c == '='
            n += -2 * 5^(length(snafu) - i - 1)
        end
    end
    return n
end=#

# SMALL_SNAFUS = Dict{Int, String}(i => snafu2dec(i) for i in 1:9)
SMALL_SNAFUS = Dict{Int, String}(
    i => s for
    (i, s) in zip(0:9, ("0", "1", "2", "1=", "1-", "10", "11", "12", "2=", "2-"))
)


# "So, because ten (in normal numbers) is two fives and no ones, in SNAFU it is written 20. Since eight (in normal numbers) is two fives minus two ones, it is written 2=."
# "You can do it the other direction, too. Say you have the SNAFU number 2=-01. That's 2 in the 625s place, = (double-minus) in the 125s place, - (minus) in the 25s place, 0 in the 5s place, and 1 in the 1s place. (2 times 625) plus (-2 times 125) plus (-1 times 25) plus (0 times 5) plus (1 times 1). That's 1250 plus -250 plus -25 plus 0 plus 1. 976!"

function dec2snafu(n::Int; base::Int = 5)
    io = IOBuffer()
    while n > 0
        c = SNAFU_CODE_UNITS_REVERSE[(n + 2) % base - 2]
        print(io, c)
        n = round(Int, n / base)
    end
    return reverse(String(take!(io)))
end

#=function dec2snafu(n::Int)
    b = 5
    io = IOBuffer()
    n₅ = parse(Int, string(n, base = b))

    s = ""

    while n > 0

    end

    # for (i, j) in zip(ndigits(n):-1:1, reverse(digits(n)))

    # end

    digs = digits(n₅)
    # for i in digits(n₅)
    i = 1
    while i <= length(n₅)
        # Check if minus works first, if not try plus
        if haskey(SNAFU_CODE_UNITS_REVERSE, i)
            s = SNAFU_CODE_UNITS_REVERSE[i]
            i += 1
        else
            # s = SMALL_SNAFUS[i] * s
            m, r = divrem(i, b)
        end
    end

    return s



    # Divide the decimal number by the largest power of 5 that is less than or equal to the number. The remainder is the value for the corresponding digit in the SNAFU number.
    m = ndigits(n)

    while !iszero(n)
        k = round(Int, fld(log(n), log(b)))
        p = b^k
        # print("$n ")
        m, n = divrem(n, p)
        println("$p, $m, $n, $(SNAFU_CODE_UNITS_REVERSE[m])")
        # print(io, SNAFU_CODE_UNITS_REVERSE[m])
        s = SNAFU_CODE_UNITS_REVERSE[m] * s
    end

    return s
    return String(take!(io))


    base = 5
    m, io = 1, IOBuffer()
    for i in digits(n)
        d = i ÷ m
        print(io, SNAFU_CODE_UNITS_REVERSE[i])
        m *= base
    end
    return String(take!(io))
end=#

# println(data)

function part1(data::Vector{Int})
    return dec2snafu(sum(data))
end



function main()
    data = parse_input("data25.txt")

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == "2=-0=01----22-0-1-10" part1_solution
    println("Part 1: $part1_solution")

    # Part 2
    # part2_solution = part2(data)
    # @assert part2_solution == ""
    # println("Part 2: $part2_solution")
end


main()
