using AdventOfCode.Parsing, AdventOfCode.Multidimensional
# using Base.Iterators
# using Statistics
# using LinearAlgebra
# using Combinatorics
# using LazySets, ModelingToolkit
# import Polyhedra
using DataStructures
# using StatsBase
# using IntervalSets
# using OrderedCollections

function parse_input(input_file::String)
    # M = readlines_into_char_matrix(input_file)
    S = strip(read(input_file, String))
    # L = strip.(readlines(input_file))
    L1, L2 = split(S, "\n\n")
    L2 = [get_integers(l) for l in split(L2, "\n")]
    L1 = strip.(split(L1, "\n"))
    L1 = [split(l, '{') for l in L1]
    L1 = [(l1, l2[1:end-1]) for (l1, l2) in L1]
    # println(L1)
    L1 = [(l1, split(l2, ',')) for (l1, l2) in L1]
    return Dict(ln => lr for (ln, lr) in L1), L2

    L1 = [(l1, [(l[1], l[2:end]) for l in l2]) for (l1, l2) in L1]
    L1 = [(l1, [(ln, split(lr, ':')...) for (ln, lr) in l2]) for (l1, l2) in L1]
    L1 = Dict(ln => lr for (ln, lr) in L1)
    # L1 = [(l1, [(ln, la[1], lt) for (ln, la, lt) in l2]) for (l1, l2) in L1]
    return L1, L2
    # L = get_integers.(L)
    return L
end

#=
    x: Extremely cool looking
    m: Musical (it makes a noise when you hit it)
    a: Aerodynamic
    s: Shiny
=#

function accepts(workflow, ratings)
    x, m, a, s = ratings
    for part in workflow
        if !(':' in part)
            if length(part) == 1
                c = only(part)
                c == 'R' && return false
                c == 'A' && return true
            end
            return part
        end
        cond, t = split(part, ':')
        cond = replace(cond, "x" => x, "m" => m, "a" => a, "s" => s)
        expr = Meta.parse(cond)
        if eval(expr)
            if length(t) == 1
                c = only(t)
                c == 'R' && return false
                c == 'A' && return true
            end
            return t
        end
    end
    error("hopefully unreachable")
end

function run(workflows, sk, ratings)
    workflow = workflows[sk]
    while true
        a = accepts(workflow, ratings)
        if a isa Bool
            return a
        else
            workflow = workflows[a]
        end
    end
end

function part1(data)
    workflows, ratings = data
    # fi = findfirst(t -> first(t) == "in", workflows)
    # ex{x>10:one,m<20:two,a>30:R,A}
    ans = 0
    for rating in ratings
        if run(workflows, "in", rating)
            ans += sum(rating)
        end
    end
    return ans
end

function construct_polygon()
    # vars = x, m, a, s = @variables x m a s
    # println(vars)
    # println(vars[1])
    p = HPolyhedron([
        x > 10,
        # Meta.eval(Meta.parse("x > 10")),
        # Base.Cartesian.lreplace!(Meta.parse("x > 10"), Base.Cartesian.LReplace(:x, x)),
        # Base.Cartesian.lreplace(Meta.parse("x > 10"), :x, x),
        # Meta.parse("x > 10"),
        # Meta.eval(Meta.parse("vars[1] > 10")),
        m < 20,
        a < 30,
        1 <= x,
        1 <= m,
        1 <= a,
        1 <= s,
        x <= 4000,
        m <= 4000,
        a <= 4000,
        s <= 4000,
    ], vars)
    return p
end

function get_variable_ranges(p)
    V1 = NTuple{2, Float64}[extrema(getindex.(vertices(p), i)) for i in 1:dim(p)]
    V2 = UnitRange{Int}[UnitRange(round.(Int, v)...) for v in V1]
    return V2
end

function get_variable_range_size(R)
    return prod(length, R)
end

function f()
    p = construct_polygon()
    R = get_variable_ranges(p)
    return get_variable_range_size(R)
end

# given a range, which part of the range follows the rule op(n)?
function new_range(op, n, r)
    low, high = extrema(r)

    # TODO: explain
    if op == ">"
        return max(low, n + 1):high
    elseif op == "<"
        return low:min(high, n - 1)
    elseif op == ">="
        return max(low, n):high
    elseif op == "<="
        return low:min(high, n)
    else
        error("unhandled op $(repr(op))")
    end
end

function new_ranges(v, op, n, ranges)
    ranges = [ranges...]
    i = findfirst(v, "xmas")
    ranges[i] = new_range(op, n, ranges[i])
    return Tuple(ranges)
    # if var == 'x'
        # ranges[1] =
        # return (new_range(op, n, xr), mr, ar, sr)
    # elseif var == 'm'
        # return (new_range())
end

#=
20679570000000
35999775000000
39201891528000
=#

#=
19114
8167885440000
30024525440000
46817229440000
73416525440000
108744525440000
117025918868000
137602348868000
152088874868000
167409079868000
167409079868000
=#

#=
in
qqz
R
hdj
pv
A
8167885440000
R
A
30024525440000
qs
lnx
A
46817229440000
A
73416525440000
A
108744525440000
px
rfg
A
117025918868000
R
gd
R
R
A
137602348868000
qkq
crn
R
A
152088874868000
A
167409079868000
167409079868000
=#

#=
in
px
qqz
qkq
A
20679570000000
rfg
qs
hdj
R
A
35999775000000
crn
gd
R
A
39201891528000
A
R
R
R
=#

DataStructures.enqueue!(S::Stack, x) = push!(S, x)
DataStructures.dequeue!(S::Stack) = pop!(S)

function part2(data)
    workflows, _ratings = data
    # f()
    ans = 0
    # Q = Queue{Any}()
    # TODO: can't I use queue?
    Q = Stack{Any}()
    r1 = 1:4000
    enqueue!(Q, ("in", ntuple(_ -> r1, 4)))
    println(workflows)

    while !isempty(Q)
        sk, ranges = dequeue!(Q)
        println(sk)

        # All ranges must be non-empty
        any(isempty(r) for r in ranges) && continue

        if sk == "A"
            ans += prod(length, ranges)
            println(ans)
            continue
        elseif sk == "R"
            continue
        else
            workflow = workflows[sk]
            for part in workflow
                # println(part)
                if ':' in part
                    cond, t = split(part, ':')
                    # @assert length(t) > 1 t
                    v, op, n = cond[1], string(cond[2]), parse(Int, cond[3:end])
                    # println(cond, " | $v $op $n")
                    enqueue!(Q, (t, new_ranges(v, op, n, ranges)))

                    op_str = op == ">" ? "<=" : ">="
                    op_str == ">=" && @assert op == "<"
                    ranges = new_ranges(v, op, n, ranges)
                else
                    enqueue!(Q, (part, ranges))
                    break
                end
            end
        end
    end

    return ans
end

function main()
    data = parse_input("data19.txt")
    data = parse_input("data19.test.txt")
    # println(data[1])
    # println(data[2][1])

    # Part 1
    part1_solution = part1(data)
    # @assert part1_solution == 391132
    println("Part 1: $part1_solution")
    @assert part1_solution == 19114

    # Part 2
    part2_solution = part2(data)
    # @assert part2_solution == 128163929109524
    println("Part 2: $part2_solution")
    @assert part2_solution == 167409079868000
end

main()
