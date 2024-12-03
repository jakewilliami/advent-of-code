# The input is a string of "corrupted data" that has instructions that
# we have to find and parse.
#
# Part one was very simple; we just had to find the multiplication
# instructions that looked like `mul(...,...)' (which is very straight
# forward using regex), apply the multiplication of the arguments, and
# sum the results.  I did this part in three minutes.
#
# For part two, we were to only apply the multiplication if the `mul'
# command occurs between `do()' and `don't' commands.  I had a solution
# to this in another few minutes that worked for the test case, but
# failed for the real data.  I eventually got there, but it too me a
# long time (and a lot of trial and error: 075f429).  The reason this
# took me so long was because the do's and don't's don't always alter-
# nate; there may, for example, be multiple do's before a don't.  And
# the solutions I was trying to write ended up being over-complicated
# and failed to account for this nuance.

function parse_input(input_file::String)
    return strip(read(input_file, String))
end

function part1(data::AbstractString)
    pat = r"mul\((?<a>\d+),(?<b>\d+)\)"

    return sum(eachmatch(pat, data)) do m
        a, b = parse.(Int, (m[:a], m[:b]))
        a * b
    end
end

function part2(data::AbstractString)
    pat = r"""
        (?<instruction>do|don't)\(\)|       # [De]activate cursor
        (?<mul>mul)\((?<a>\d+),(?<b>\d+)\)  # Multiplication command
    """x
    enabled = true

    return sum(findall(pat, data)) do r
        # Get RegexMatch object from data view at match
        m = match(pat, data[r])
        @assert !isnothing(m)

        # Instantiate multiplication components
        a, b = 0, 0

        # Handle instructions
        if haskey(m, :instruction) && !isnothing(m[:instruction])
            # Handle [de]activation of the cursor
            if m[:instruction] == "do"
                enabled = true
            elseif m[:instruction] == "don't"
                enabled = false
            else
                error("Unhandled instruction $(repr(m[:instruction]))")
            end
        elseif haskey(m, :mul) && !isnothing(m[:mul])
            # Set multiplication components if the cursor is enabled
            @assert m[:mul] == "mul"
            if enabled
                a, b = parse.(Int, (m[:a], m[:b]))
            end
        else
            error("Unhandled regex match $(repr(m))")
        end

        a * b
    end
end

function main()
    data = parse_input("data03.txt")

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == 165225049
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    @assert part2_solution == 108830766
    println("Part 2: $part2_solution")
end

main()
