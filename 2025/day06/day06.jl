# Description: what was the problem; how did I solve it; and (optionally)
# any thoughts on the problem or how I did.

#  ]add ~/projects/AdventOfCode.jl Statistics LinearAlgebra Combinatorics DataStructures StatsBase IntervalSets OrderedCollections MultidimensionalTools
# using AdventOfCode.Parsing, AdventOfCode.Multidimensional
# using Base.Iterators
# using Statistics
# using LinearAlgebra
# using Combinatorics
# using DataStructures
# using StatsBase
# using IntervalSets
# using OrderedCollections
# using MultidimensionalTools


### Parse Input ###

function parse_input(input_file::String)
    # M = readlines_into_char_matrix(input_file)
    # S = strip(read(input_file, String))
    L = strip.(readlines(input_file))
    A = [only(x) for x in split(last(L))]
    L = [[parse(Int, x) for x in split(l)] for l in L[1:end-1]]
    M = Matrix{Int}(undef, length(L), length(L[1]))
    for ri in 1:length(L)
        r = L[ri]
        for ci in 1:length(r)
            c = r[ci]
            M[ri, ci] = c
        end
    end
    # L = get_integers.(L)
    return M, A
end


### Part 1 ###

function part1(data)
    M, A = data
    r = 0
    for i in 1:length(A)
        c = M[:, i]
        e = A[i]
        if e == '*'
            r += prod(c)
        elseif e == '+'
            r += sum(c)
        end
    end
    r
end


### Part 2 ###

function apply_pad(v0, fnc)
    v = deepcopy(v0)
    n = maximum(length, v)
    v2 = []
    for i in 1:length(v)
        d = v[i]
        println("  $d")
        for i in 1:n - length(d)
            # if fnc == '*'
                # push!(d, 0)
            # elseif fnc == '+'
            println("    pushing")
                pushfirst!(d, 0)
            # end
        end
        push!(v2, d)
    end
    return v2
end

function reint(v, fnc)
    d0 = [digits(n) for n in v]
    # d = deepcopy(d0)
    d = apply_pad(d0, fnc)
    @assert all(length(d[1]) == length(x) for x in d)
    v2 = []
    for i in 1:maximum(length, d)
        #=local r
        if fnc == '*'
            r = 1
        elseif fnc == '+'
            r = 0
        end=#
        # println(d0[i])
        # d2 = [x[i] for x in d]
        d2 = reverse([x[i] for x in d if i ∈ 1:length(x)])
        # d2 = reverse([x[i] for x in d])
        # println(d2)
        push!(v2, parse(Int, join(d2)))
    end
    v2
end

# similar to yesterday, not particularly hard but logic i haven't thought of really
function newreint(v, fnc)
    ns = [ndigits(x) for x in v]
    ds = [digits(x) for x in v]
    # v2 = [[] for _ in v]
    v2 = []

    for i in 1:maximum(ns)
        # nd = ns[i]
        #=t = []
        if i <= nd
            for j in 1:length(v)
                x = ds[j][i]
                push!(t, x)
            end
        end
        push!(v2, t)=#
        #=for j in 1:length(v)
            nd = ns[j]
            if i <= nd
                push!(v2[j], ds[j][i])
            end
        end=#
        t = [x[i] for x in ds if i ∈ 1:length(x)]
        push!(v2, t)
    end
    v2
end

function part20(data)
    M, A = data
    r = 0
    for i in length(A):-1:1
        c = M[:, i]
        fnc = A[i]
        # println(reint(c, fnc))
        # new_c = reint(c, fnc)
        new_c = newreint(c, fnc)
        println(new_c)
        # if fnc == '*'
            # r += prod(new_c)
        # elseif fnc == '+'
            # r += sum(new_c)
        # end
    end
    r
end

function new_parse_input(input_file::String)
    L = readlines(input_file)
    A = [only(x) for x in split(last(L))]

    # M = []
    # L2 = []
    # for l in L[1:end-1]
        # a = split(l, ' ')
        # push!(L2, a)
    # end

    #=L = [[parse(Int, x) for x in split(l)] for l in L[1:end-1]]
    M = Matrix{Int}(undef, length(L), length(L[1]))
    for ri in 1:length(L)
        r = L[ri]
        for ci in 1:length(r)
            c = r[ci]
            M[ri, ci] = c
        end
    end
    # L = get_integers.(L)
    return M, A=#

    # return L2, A
    return L, A
end

function part2(data)
    lines, ops = data
    lines = lines[1:end-1]
    @assert all(length(lines[1]) == length(l) for l in lines)
    @assert all(length(split(lines[1])) == length(split(l)) for l in lines)

    ncols = length(split(lines[1]))
    ncols = length(lines[1])
    nrows = length(lines)
    v = []
    ds = []

    wi = 1
    for ci in ncols:-1:1
        # check if all spaces - if so, we increment
        if all(isspace(l[ci]) for l in lines)
            # push!(v, ds)
            # empty!(ds)
            wi += 1
        end

        # for ri in 1:length()
        # end
        # println(ci)
        s = ""
        for l in lines
            c = l[ci]
            # println("  '$c'")
            if isspace(c)
                continue
            end
            # push!(ds, c)
            s *= c
        end
        # push!(v, s)
        # empty!(ds)
        push!(v, s)
    end

    v2 = []
    i = 1
    while i <= length(v)
        t = []
        while i <= length(v) && !isempty(v[i])
            push!(t, v[i])
            i += 1
        end
        push!(v2, t)
        i += 1
    end

    # println(v2)
    # lines

    v2 = [[parse(Int, x) for x in d] for d in v2]
    r = 0
    for (i, v) in enumerate(reverse(v2))
        fnc = ops[i]
        # println(v)
        if fnc == '*'
            # println("  ", prod(v))
            r += prod(v)
        elseif fnc == '+'
            # println("  ", sum(v))
            r += sum(v)
        end
    end
    r
end


### Main ###

function main()
    data = new_parse_input("data06.txt")
    p1data = parse_input("data06.txt")
    # data = new_parse_input("data06.test.txt")
    # println(data)

    # Part 1
    part1_solution = part1(p1data)
    @assert part1_solution == 4693419406682
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    @assert part2_solution == 9029931401920
    println("Part 2: $part2_solution")
end

main()
