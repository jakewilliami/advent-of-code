# nonagrams

using DataStructures

function parse_input(input_file::String)
    L = [split(s) for s in eachline(input_file)]
    return [(l1, parse.(Int, split(l2, ','))) for (l1, l2) in L]
end

# A block of a certain character has a start index in the string, and a length of the block
struct ArrangementBlock
    c::Char
    si::Int
    length::Int
end

const Arrangements = Dict{Int, ArrangementBlock}

function _arrangement(line)
    # (char, start i, length)
    A = []
    n, i, j, c = 1, 1, 1, line[1]
    while i < length(line)
        # println("$i $n $c $(line[i]) $(line[i+1])")
        i += 1
        c2 = line[i]
        if c2 != c
            push!(A, (c, j, n))
            c = c2
            n = 1
            j = i
        else
            n += 1
        end
        i == length(line) && push!(A, (c, j, n))
    end
    return A
end

function __arrangement(line)
    A = IntervalTree{Int, Interval{Int}}()
    for a in _arrangement(line)
    end
end

function is_valid(line, blocks, ci, bi, li)
    if bi > length(blocks) && li == 0
        # The configuration is valid if ...
        return true  # is valid
    elseif bi == length(blocks) && blocks[bi] == li
        # The configuration is valid if ...
        return true # is valid
    else
        return false # invalid configuration
    end
end

function is_valid(line, blocks, arrangements, i)
    a = arrangements[]
    if i
end

#=I did a similar DP solution but with a slightly smaller state space: The current position in the string, and the current position in the constraints (conditions) list. Using @cache, it's enough to just literally pass the sliced string and sliced constraints list as parameters. While the number of states is bounded by (length of string) * (number of constraints), in practice, the number of states needed to be explored is much smaller.

If I see a #, then I consume the first item, say n, in the constraints list, and make sure there's exactly n contiguous hashes afterwards. If so, then I consume the hashes and an additional dot, then count the rest recursively. Of course I also have to handle other edge cases not mentioned here

If I see a dot, then I just slice the string once at the start and count the rest recursively.

If I see a ? then I perform both operations above and sum the results.=#

function n_arrangements(line, blocks, arrangements, i)
    i > length(line) && return is_valid(line, blocks, arrangements, i)
end


# ci = current position within dots
# bi = current position within blocks
# ai = current position within arrangement
# bl = length of current block of '#'

# ci = what character we're looking at
# bi = which block we're trying to fill out currently
# bl = how long our current block of hashes is
function n_arrangements(line, blocks, ci, bi, bl, D = Dict())
    # Go left to right, bfs??
    # D = Dict()
    # char, start i, block length
    # c1, si, bl = arrangement[ai]
    # if ci == si + bl - 1
    # https://github.com/jonathanpaulson/AdventOfCode/blob/341185efbe64ce771a57aef7d2bd101d9ea09329/2023/12.py
    # https://www.reddit.com/r/adventofcode/comments/18ge41g/comment/kd03uf3/
    k = (ci, bi, bl)
    println()

    l_repr = "\"$(line)[]\""
    if ci < length(line)
        l_repr = "\"$(line[1:ci-1])[$(line[ci])]$(line[ci+1:end])\""
    end
    b_repr = "($(join(blocks, ", ")), [])"
    if bi < length(blocks)
        b_repr_arr = Vector{Any}(undef, length(blocks))
        copyto!(b_repr_arr, blocks)
        b_repr_arr[bi] = "[$(blocks[bi])]"
        b_repr = "($(join(b_repr_arr, ", ")))"
    end
    println("ci=$ci, bi=$bi, bl=$bl (line=$l_repr, blocks=$b_repr)")

    k in keys(D) && println("  memoised")
    k in keys(D) && return D[k]

    # We have reached the end of the line.  Check if the configuration is valid.
    ci > length(line) && println("  reached end of line; is valid: $(is_valid(line, blocks, ci, bi, bl))")
    ci > length(line) && return is_valid(line, blocks, ci, bi, bl)

    # Recurse into next possibilities
    # if we're not at the end of a line, then we can consider putting either a dot or octothorp at the current position
    # if current character is a question mark we can put either dot or octothorp, otherwise we must put that character
    ans, c = 0, line[ci]
    # println("  line[ci]='$(line[ci])'")

    if c in ('.', '?')
        if bl == 0
            # bl == 0 means that we previously had a dot, but c is . or ? (considered .) so we're still on the same block.  increment the character index
            println("  case 1")
            ans += n_arrangements(line, blocks, ci + 1, bi, 0, D)
        elseif bi <= length(blocks) && blocks[bi] == bl
            # in this case, bl must be > 0, so we are ending a block, and it's the right expected length. then we havve to increment the block counter as well, currently the # is length of zero
            @assert bl > 0
            println("  case 2")
            # start block again
            ans += n_arrangements(line, blocks, ci + 1, bi + 1, 0, D)
        end
    end

    if c in ('#', '?')
        # an octothrop will always just increment the length of the current block
        println("  case 3")
        ans += n_arrangements(line, blocks, ci + 1, bi, bl + 1, D)
    end

    D[k] = ans
    return ans

    # println("AFTER : '$config', $blocks, $arr")


    return 0
end

# non-reursive
function n_arrangements_non_recursive_not_working(line, blocks, ci, bi, li, D = Dict())
    # Go left to right, bfs??
    # D = Dict()
    # char, start i, block length
    # c1, si, bl = arrangement[ai]
    # if ci == si + bl - 1
    # https://github.com/jonathanpaulson/AdventOfCode/blob/341185efbe64ce771a57aef7d2bd101d9ea09329/2023/12.py
    # https://www.reddit.com/r/adventofcode/comments/18ge41g/comment/kd03uf3/
    S = Stack{Tuple{Int, Int, Int, Int}}()
    push!(S, (ci, bi, li, 0))

    res = 0
    while !isempty(S)
        ci, bi, li, ans = pop!(S)
        k = (ci, bi, li)
        # k in keys(D) && return D[k]
        k in keys(D) && continue

        # println("ci = $ci, length(line) = $(length(line))")
        if ci > length(line)
            if bi > length(blocks) && li == 0
                # D[k] = 1
                ans += 1
            elseif bi == length(blocks) && blocks[bi] == li
                # D[k] = 1
                ans += 1
            else
                # D[k] = 0
                ans += 0
            end
        else
            # ans = 0
            for c in ('.', '#')
                if line[ci] in (c, '?')
                    if c == '.' && li == 0
                        # ans += n_arrangements(line, blocks, ci + 1, bi, 0, D)
                        push!(S, (ci + 1, bi, 0, ans))
                    elseif c == '.' && li > 0 && bi <= length(blocks) && blocks[bi] == li
                        # ans += n_arrangements(line, blocks, ci + 1, bi + 1, 0, D)
                        push!(S, (ci + 1, bi + 1, 0, ans))
                    elseif c == '#'
                        # ans += n_arrangements(line, blocks, ci + 1, bi, li + 1, D)
                        push!(S, (ci + 1, bi, li + 1, ans))
                    end
                end
            end
            D[k] = ans
        end
    end

    # println("AFTER : '$config', $blocks, $arr")


    return 0
end

function part1(data)
    res = 0
    # println(arrangement(first(last(data))))
    for (line, blocks) in data
        # arrangement = _arrangement(line)
        res += n_arrangements(line, blocks, 1, 1, 0)
        # println(n_arrangements(line, blocks, 1, 1, 0))
    end
    return res
end

function part2(data)
    res = 0
    repeat_coeff = 5
    # println(arrangement(first(last(data))))
    # println(D)
    for (line, blocks) in data
        D = Dict()
        # arrangement = _arrangement(line)
        # print(blocks)
        line = join(repeat([line], repeat_coeff), '?')
        blocks = repeat(blocks, repeat_coeff)
        # println("$line $blocks")
        # println(" -> $blocks")
        res += n_arrangements(line, blocks, 1, 1, 0, D)
        # println(D)
        # println(n_arrangements(line, blocks, 1, 1, 0, D))
    end
    return res
end

function main()
    data = parse_input("data12.txt")
    # data = parse_input("data12.test.txt")
    # println(data)
    l = data[1]
    n_arrangements(l..., 1, 1, 0)

    return

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == 7599
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    @assert part2_solution == 15454556629917
    println("Part 2: $part2_solution")
    # 7776000 too low
    # 1024000 too low
end


main()
