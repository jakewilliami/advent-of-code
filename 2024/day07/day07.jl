# Each line of the input contained an expected value on the left, and
# a list of numbers on the right.  We had to find if some combination
# of selected operators applied from left to right to the components
# would make the left hand value.
#
# In part one, the allowed operators were plus and multiplication.  In
# part two, we were also allowed to concatonate numbers together as if
# they were strings.
#
# I did okay today, but I wasn't particularly fast.  I had no real bugs
# in the program because I did it in the simplest way I could think to
# do it: brute force.  The only problem I had was remembering how to
# generate all possible combinations of operators.  I was trying solutions
# with Combinatorics.jl but forgot that this is simple and can be done
# using Base.Iterators.product.  I was also doing this at a party
# (a family friend's 60th) and was talking through my thinking to an
# interested party-goer.
#
# I couldn't think of one, but similar to yesterday, I do wonder what
# the better, non-brute-force solution to this is.  (And I am once
# again grateful to be using Julia for its speed.)
#
# Jonathan Paulson has a really elegant solution using recursion and
# utilising the fact that it's evaluated from left to right:
# <https://github.com/jonathanpaulson/AdventOfCode/blob/c58061ba/2024/7.py#L14-L23>

using AdventOfCode.Parsing, AdventOfCode.Multidimensional

### Parse Input ###

struct UnsetEquation
    expected::Int
    components::Vector{Int}
end

function parse_input(input_file::String)
    L = strip.(readlines(input_file))
    A = UnsetEquation[]
    for line in L
        a, b = strip.(split(line, ':'))
        a, b = parse(Int, a), parse.(Int, split(b))
        push!(A, UnsetEquation(a, b))
    end
    return A
end


### Part 1 ###

function op_combinations(e::UnsetEquation, ops::NTuple{N, Symbol}) where {N}
    n = length(e.components) - 1
    return Base.Iterators.product((ops for i in 1:n)...)
end

function get_op(op_s::Symbol)
    op = identity
    if op_s == :+
        op = +
    elseif op_s == :*
        op = *
    elseif op_s == :||
        # Additional handling of new operator for part 2
        # The naïve string joining for concat op is much slower
        # op = (a, b) -> parse(Int, join((a, b)))
        op = (a, b) -> a * 10^ndigits(b) + b
    else
        error("Unhandled operator: $op_s")
    end
    return op
end

function apply_op(e::UnsetEquation, ops::NTuple{N, Symbol}) where {N}
    @assert length(ops) > 1
    r = get_op(ops[1])(e.components[1], e.components[2])
    for i in 2:length(ops)
        op_s = ops[i]
        op = get_op(ops[i])
        @assert op != identity
        r = op(r, e.components[i + 1])
    end
    return r
end

function applied_expected(e::UnsetEquation, ops::NTuple{N, Symbol}) where {N}
    @assert length(ops) == length(e.components) - 1
    return apply_op(e, ops) == e.expected
end

function compute_ans(data::Vector{UnsetEquation}; ops::NTuple{N, Symbol}) where {N}
    sum(data) do e
        any(applied_expected(e, op) for op in op_combinations(e, ops)) ||
            return 0
        e.expected
    end
end

part1(data::Vector{UnsetEquation}) = compute_ans(data, ops = (:+, :*))


### Part 2 ###

part2(data::Vector{UnsetEquation}) = compute_ans(data, ops = (:+, :*, :||))


### Main ###

function main()
    data = parse_input("data07.txt")

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == 5030892084481
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    @assert part2_solution == 91377448644679
    println("Part 2: $part2_solution")
end

main()
