# Description: what was the problem; how did I solve it; and (optionally)
# any thoughts on the problem or how I did.

#  ]add https://github.com/jakewilliami/AdventOfCode.jl Statistics LinearAlgebra Combinatorics DataStructures StatsBase IntervalSets OrderedCollections MultidimensionalTools
using AdventOfCode.Parsing, AdventOfCode.Multidimensional
using Memoization
using DataStructures


### Parse Input ###

function parse_input(input_file::String)
    M = readlines_into_char_matrix(input_file)
    return M
    # S = strip(read(input_file, String))
    L = strip.(readlines(input_file))
    # L = get_integers.(L)
    return L
end


### Part 1 ###

function getstart(M)
    for i in CartesianIndices(M)
        if M[i] == 'S'
            return i
        end
    end
    error()
end

const Index = CartesianIndex

function part1(data)
    M = data
    si = getstart(M)
    d = INDEX_DOWN
    a = 0
    Q = Queue{Index}()
    push!(Q, si)  # + d
    seen = Set{Index}()
    while !isempty(Q)
        i = popfirst!(Q)
        i ∈ seen && continue
        push!(seen, i)
        c = M[i]
        if c == '^'
            push!(Q, i + INDEX_LEFT)
            push!(Q, i + INDEX_RIGHT)
            a += 1
        else
            j = i + INDEX_DOWN
            if hasindex(M, j)
                push!(Q, j)
            end
        end
    end
    a
end


### Part 2 ###

function count_paths(M, i, seen)
    i ∈ seen && return 0
    push!(seen, i)

    c = M[i]

    if c == '^'
        # two branches, so we sum the number of paths in each
        return count_paths(M, i + INDEX_LEFT, copy(seen)) +
               count_paths(M, i + INDEX_RIGHT, copy(seen))
    else
        # straight path
        j = i + INDEX_DOWN
        if hasindex(M, j)
            return count_paths(M, j, copy(seen))
        else
            # dead end means one complete path
            return 1
        end
    end
end

#=function part2(data)
    M = data
    si = getstart(M)
    answer = 0
    Q = Queue{Index}()
    push!(Q, si)  # + d
    seen = Set{Index}()
    while !isempty(Q)
        i = popfirst!(Q)
        i ∈ seen && continue
        push!(seen, i)
        c = M[i]
        if c == '^'
            push!(Q, i + INDEX_LEFT)
            push!(Q, i + INDEX_RIGHT)
            answer += 1
        else
            j = i + INDEX_DOWN
            if hasindex(M, j)
                push!(Q, j)
            end
        end
    end
    answer
end=#

function part2(data)
    M = data
    si = getstart(M)
    return count_paths(M, si, Set{Index}())
end

function part2(data)
    M = data
    si = getstart(M)
    S = Stack{Tuple{Index, Set{Index}}}()
    push!(S, (si, Set{Index}()))
    a = 0

    while !isempty(S)
        i, seen = pop!(S)
        if i ∈ seen
            continue
        end
        push!(seen, i)

        c = M[i]

        if c == '^'
            # fork: push two new independent branches
            push!(S, (i + INDEX_LEFT,  copy(seen)))
            push!(S, (i + INDEX_RIGHT, copy(seen)))

        else
            # straight path
            j = i + INDEX_DOWN
            if hasindex(M, j)
                push!(S, (j, seen))
            else
                # dead end means one complete path
                a += 1
            end
        end
    end


    return a
end

function count_paths_dp(M)
    si = getstart(M)

    # First: collect all reachable nodes so we know what to DP over
    reachable = Set{Index}()
    Q = Queue{Index}()
    push!(Q, si)
    while !isempty(Q)
        i = popfirst!(Q)
        i ∈ reachable && continue
        push!(reachable, i)

        c = M[i]
        if c == '^'
            push!(Q, i + INDEX_LEFT)
            push!(Q, i + INDEX_RIGHT)
        else
            j = i + INDEX_DOWN
            hasindex(M, j) && push!(Q, j)
        end
    end

    # DP table: number of paths from i to any leaf
    # paths = Accumulator{Index, Int}()
    paths = Dict{Index, Int}()

    # Sort reachable nodes in decreasing row order
    # (nodes lower in the grid get evaluated first)
    nodes = collect(reachable)
    sort!(nodes, by = i -> Tuple(i)[1], rev = true)

    for i in nodes
        c = M[i]
        if c == '^'
            left  = i + INDEX_LEFT
            right = i + INDEX_RIGHT
            paths[i] = get(paths, left, 0) + get(paths, right, 0)
        else
            j = i + INDEX_DOWN
            if hasindex(M, j)
                paths[i] = paths[j]
            else
                # a leaf
                paths[i] = 1
            end
        end
    end

    return paths[si]
end

function part2(data)
    M = data
    return count_paths_dp(M)
end

function part2(data)
    M = data
    si = getstart(M)
    answer = 0
    Q = Queue{Tuple{Index, Int}}()
    push!(Q, (si, 0))  # + d
    seen = Set{Index}()
    DP = Dict{Index, Int}()
    while !isempty(Q)
        i, n = popfirst!(Q)
        if i ∈ DP
            answer += (DP[i])
            continue
        else
            DP[i] = n
        end
        # i ∈ seen && continue
        # push!(seen, i)
        c = M[i]
        if c == '^'
            push!(Q, (i + INDEX_LEFT, n + 1))
            push!(Q, (i + INDEX_RIGHT, n + 1))
            answer += 1
        else
            j = i + INDEX_DOWN
            if hasindex(M, j)
                push!(Q, (j, n + 1))
            end
        end
    end
    answer
end

# DP = Dict{Index, Int}()

@memoize function score(i, M)
    j = i + INDEX_DOWN
    !hasindex(M, j) && return 1

    if M[j] == '^'
        return score(j + INDEX_LEFT, M)+score(j+ INDEX_RIGHT, M)
    end

    return score(j, M)
end

function part2(data)
    M = data
    si = getstart(M)
    score(si, M)
    #=Q = Queue{Index}()
    push!(Q, si)
    S = Set{Index}()
    while !isempty(Q)
        i = popfirst!(Q)
        if i ∈ S
            continue
        end
        push!(S, i)
        if !hasindex()
    end=#
end

function scorei(si, M)
    DP = Dict{Index,Int}()

    S = Stack{Index}()
    push!(S, si)

    while !isempty(S)
        i = pop!(S)

        # If we've already computed this node, skip it
        haskey(DP, i) && continue

        j = i + INDEX_DOWN


        # leaf node
        if !hasindex(M, j)
            DP[i] = 1
            continue
        end

        #=if M[j] == '^'
            j1, j2 = j + INDEX_LEFT, j + INDEX_RIGHT
            haskey(DP, j1) || push!(stack, (j1, false))
            haskey(DP, j2) || push!(stack, (j2, false))
        else
            haskey(DP, j) || push!(stack, (j, false))
        end=#

        if M[j] == '^'
            j1, j2 = j+INDEX_LEFT, j+INDEX_RIGHT
            if haskey(DP, j1) && haskey(DP, j2)
                # println("$i $j $j1 $j2")
                DP[i] = DP[j1] + DP[j2]
            else
                # push parent back onto stack so that we can compute it again once all children nodes are ready/have been memoised
                push!(S, i)
                push!(S, j1)
                push!(S, j2)
            end
        else
            if haskey(DP, j)
                DP[i] = DP[j]
            else
                # push parent back onto stack so that we can compute it again once all children nodes are ready/have been memoised
                push!(S, i)
                push!(S, j)
            end
        end

        # Node has children: either straight-down or a fork
        #=if !expanded
            # First time we see this node:
            # push it back with expanded=true so we compute AFTER children
            push!(stack, (i, true))

            if M[j] == '^'
                # fork: two children
                push!(stack, (j + INDEX_LEFT, false))
                push!(stack, (j + INDEX_RIGHT, false))
            else
                # straight
                push!(stack, (j, false))
            end

        else
            # Second time: children are guaranteed computed read DP
            if M[j] == '^'
                DP[i] = DP[j + INDEX_LEFT] + DP[j + INDEX_RIGHT]
            else
                DP[i] = DP[j]
            end
        end=#
    end

    return DP[si]
end


function part2(data)
    M = data
    si = getstart(M)
    return scorei(si, M)
end


### Main ###

function main()
    data = parse_input("data07.txt")
    # data = parse_input("data07.test.txt")
    # println(data)

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == 1592
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    @assert part2_solution == 17921968177009
    println("Part 2: $part2_solution")
end

main()
