using AdventOfCode.Parsing, AdventOfCode.Multidimensional
# using Base.Iterators
# using Statistics
# using LinearAlgebra
# using Combinatorics
# using DataStructures
# using StatsBase
# using IntervalSets
# using OrderedCollections

struct Wire
    value::String
end

Wire(p::Char, i::Int) = Wire("$(p)$(lpad(i, 2, '0'))")

@enum Operator begin
    AND
    OR
    XOR
end

OPS = Dict{String, Operator}(
    "AND" => AND,
    "OR" => OR,
    "XOR" => XOR,
)

struct Equation
    a::Wire  # input
    b::Wire  # input
    op::Operator  # gate
    c::Wire  # output
end

function parse_input(input_file::String)
    # M = readlines_into_char_matrix(input_file)
    S = strip(read(input_file, String))
    S1, S2 = split(S, "\n\n")
    D1 = Dict(Pair(split(l, ": ")...) for l in split(S1, "\n"))
    D1 = Dict(Wire(String(k)) => parse(Int, v) for (k, v) in D1)
    L2′ = split.(split(S2, '\n'))
    operands = [Tuple(String.((l[1], l[3]))) for l in L2′]
    ops = [OPS[String(l[2])] for l in L2′]
    outs = [String(last(l)) for l in L2′]
    eqns = Equation[]
    @assert length(outs) == length(operands) == length(ops)
    for i in 1:length(outs)
        push!(eqns, Equation(Wire(operands[i][1]), Wire(operands[i][2]), ops[i], Wire(outs[i])))
    end
    # D1 are initial inputs for the entire system, and eqns are gate definitions
    D2 = Dict()
    for eqn in eqns
        D2[eqn.c] = eqn
    end
    return D1, D2
    # L = strip.(readlines(input_file))
    # L = get_integers.(L)
    #=
    x00 AND y00 -> z00
    x01 XOR y01 -> z01
    x02 OR y02 -> z02
    =#
    return L
end

function and(a, b)
    # AND gates output 1 if both inputs are 1; if either input is 0, these gates output 0
    @assert all(∈((0, 1)), (a, b)) "undefined"
    a == b == 1 && return 1
    (a == 0 || b == 0) && return 0
    error("undefined")
end

function or(a, b)
    # OR gates output 1 if one or both inputs is 1; if both inputs are 0, these gates output 0
    @assert all(∈((0, 1)), (a, b)) "undefined"
    a + b > 0 && return 1
    a == b == 0 && return 0
    error("undefined")
end

function xor_(a, b)
    # XOR gates output 1 if the inputs are different; if the inputs are the same, these gates output 0
    @assert all(∈((0, 1)), (a, b)) "undefined"
    a != b && return 1
    a == b && return 0
    error("undefined")
end

OP_FUNCS = Dict{Operator, Function}(
    AND => and,
    OR => or,
    XOR => xor_,
)

function evaluate!(V, gates, init)
    if !haskey(gates, init)
        if haskey(V, init)
            # if we got here, then we have evaluated a variable whose value has already been set
            return V[init]
        end
        error("$init does not have a gate or variable assignment: $gates, $V")
    end

    # Now we need to evaluate the variable based on the equation defined
    eqn = gates[init]
    a, b = evaluate!(V, gates, eqn.a), evaluate!(V, gates, eqn.b)
    V[init] = OP_FUNCS[eqn.op](a, b)
    return V[init]
end

#=
Ultimately, the system is trying to produce a number by combining the bits on all wires starting with z. z00 is the least significant bit, then z01, then z02, and so on.
=#

function solve!(V, gates, prefix::Char = 'z')
    i = 0
    res = Int[]
    while true
        wi = Wire(prefix, i)
        haskey(gates, wi) || return isempty(res) ? 0 : parse(Int, join(res), base = 2)
        r = evaluate!(V, gates, wi)
        @assert ndigits(r) == 1
        pushfirst!(res, r)
        i += 1
    end
end

function part1(data)
    # D1 are initial inputs for the entire system, and eqns are gate definitions
    V, gates = data
    # map(println, collect(V))
    solve!(copy(V), gates)
end

function part2(data)
    V, gates = data
    solved(V, gates)
    # solve!(copy(V), gates, 'x')
end

function main()
    data = parse_input("data24.txt")
    # data = parse_input("data24.test2.txt")
    # data = parse_input("data24.test.txt")

    # Part 1
    part1_solution = part1(data)
    # @assert part1_solution ==
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    # @assert part2_solution ==
    println("Part 2: $part2_solution")
end

main()
