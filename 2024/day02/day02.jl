function parse_input(input_file::String)
    return Vector{Int}[parse.(Int, split(l)) for l in eachline(input_file)]
end

# Each input vector is a "report," consisting of five "levels."  A report
# is "safe" if the levels either gradually increase or decrease; that is
# increase or decrease in not-too-large increments.
function is_safe(v::Vector{Int})
    function all_op(v::Vector{Int}, op)
        all(2:length(v)) do i
            op(v[i - 1], v[i])
        end
    end

    # First, check that they are gradually increasing or decreasing.
    all_op(v, <) || all_op(v, >) || return false

    # Then, confirm that the increments or decrements are not too large.
    return all(2:length(v)) do i
        1 <= abs(v[i - 1] - v[i]) <= 3
    end
end

part1(data) = sum(is_safe(v) for v in data)

# For part two, we can classify a "report" as "safe" if any one of the
# "levels" can be removed and the remaining report is safe (as defined
# in part 1).
function part2(data)
    # A very naïve implementation to check that a report is safe if we
    # remove any one of its levels.
    function is_safe′(v::Vector{Int})
        for i in eachindex(v)
            v′ = deepcopy(v)
            deleteat!(v′, i)
            if is_safe(v′)
                return true
            end
        end
        return false
    end

    return sum(is_safe′(v) for v in data)
end

function main()
    data = parse_input("data02.txt")

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == 202
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    @assert part2_solution == 271
    println("Part 2: $part2_solution")
end

main()
