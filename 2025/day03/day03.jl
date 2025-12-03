# Interesting problem today.  The puzzle input consists of some lines of numbers.
# Each line represents a "bank" of batteries, which are made up of batteries (each
# character on said line).  Each battery has a single-digit numerical value,
# representing its "joltage."
#
# In the first part, we are to find the two batteries in each bank that construct
# a two-digit number.  For example, the bank:
#   "12345 and you turn on batteries 2 and 4, the bank would produce 24 jolts.
#    (You cannot rearrange batteries.)"
#
# In the second part, instead of two batteries making up the bank, we had to use
# twelve.
#
# Both of my solutions were rather naïve.  I'm sure there's a better way to do
# this but I started from the most significant bits of each number and iteratively
# worked my way up, leaving enough batteries to choose from at the end of the bank,
# until I found my answer.
#
# I tried one solution by removing the smallest numbers from each bank, as it
# takes fewer iterations to find the answer.  This worked for some but not all
# banks.
#
# Honestly, I have no intuition around how better one might solve this.  I am going
# to watch Jonathan Paulson or Nim, now.
#
# NOTE: JP used brute force for the first one (similar to day 1 2020), and dynamic
# programming/memoisation for the second.  The latter was more of a recursive solution.
# Once again, I prefer iterative.  I'm pretty sure mine is greedy and his was not.


### Parse Input ###

const Battery = Int
const Bank = Vector{Int}

function parse_input(input_file::String)
    A = Bank[]

    for line in eachline(input_file)
        batteries = collect(line)
        bank = Battery[parse(Int, b) for b in batteries]
        push!(A, bank)
    end

    return A
end


### Part 1 ###

function calculate_joltage₁(bank::Bank)
    # Step 1: find the largest number to go in the 10s position.
    # We do this greedily and we need to leave room for the second number.

    a = nothing

    for n in 9:-1:1
        if n ∈ bank[1:end-1]
            a = n
            break
        end
    end

    @assert !isnothing(a)

    # Step 2: get the next best candidate number, which must _succeed_
    # the 10s place digit, so we look at the remainder of the string.

    i = findfirst(==(a), bank)

    b = maximum(i + 1:length(bank)) do j
        bank[j]
    end

    return 10a + b
end

# Sum together all of the best joltages (using some algorithm `best_joltage`)
# from the array of power bank.
function sum_joltages(data::Vector{Bank}, best_joltage)
    return sum(data) do x
        best_joltage(x)
    end
end

part1(data::Vector{Bank}) = sum_joltages(data, calculate_joltage₁)


### Part 2 ###

# Naïve algorithm to find the first largest number before i places
# the end of the array of batteries (bank).
function findfirst_max_with_right_pad(bank::Bank, i::Int)
    for n in 9:-1:1
        if n ∈ bank[1:end-i]
            return n
        end
    end

    error("unreachable")
end

function calculate_joltage₂(bank::Bank)
    bank = deepcopy(bank)
    n_digits = 12

    # Iteratively build the largest number in the same way we did
    # part 1, but 12 times.  It's janky, I know.

    res, i = 0, 0

    for j in n_digits:-1:1
        bank = bank[i + 1:end]
        n = findfirst_max_with_right_pad(bank, j - 1)
        res += n * 10^(j - 1)
        i = findfirst(==(n), bank)
    end

    return res
end

part2(data) = sum_joltages(data, calculate_joltage₂)


### Main ###

function main()
    data = parse_input("data03.txt")

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == 17535
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    @assert part2_solution == 173577199527257
    println("Part 2: $part2_solution")
end

main()
