using CircularList


f = "data20.txt"
f = "test.txt"

data = parse.(Int, readlines(f))

# println(data)

function build_lookup_table(L::CircularList.List{T}) where T
    # lookup = Union{Nothing,CircularList.Node}[nothing for _ in 1:length(L)]
    # lookup = Vector{CircularList.Node}(undef, length(L))
    # lookup = Dict{Tuple{Int, T}, CircularList.Node}()
    # lookup = Dict{T, CircularList.Node}()
    lookup = Vector{CircularList.Node}(undef, length(L))
    for i in 1:length(L)
        node = current(L)
        # lookup[(i, node.data)] = node
        lookup[i] = node
        forward!(L)
    end
    return lookup
end

function sort_list!(A, lookup; modifier = 1)


    # for (i, v) in enumerate(data)
    # w = current(L)
    # for ((n, v), w) in (lookup)
    # for (n, w) in lookup
    for n in 1:length(A)
        # w = lookup[(n, v)]
        w = lookup[n]
        jump!(A, w)  # jump to the nth node
        # w = current(A)
        # print("Processing ($n, $v) (w = $w, ")
        delete!(A)  # delete current head from list
        # shift!(A, abs(w.data), sign(w.data) == 1 ? :forward : :backward)  # shift current head position
        # shift!(A, mod(w.data, length(data)), sign(w.data) == 1 ? :forward : :backward)  # shift current head position
        shift!(A, mod((w.data) * modifier, length(A)), sign(w.data) == 1 ? :forward : :backward)  # shift current head position
        insert!(A, w.data)
        # println("$(w.data) -> $(mod((w.data), length(A))) => $([a for a in A])")
        # shift!(A, abs(v) - 1, sign(v) == 1 ? :backward : :forward)
        # println("state = $A, w = $(current(A)))")
        # w = w.next
    end

    return A
end


function grove_coordinates_sum!(A; modifier = 1)
    while !iszero(current(A).data)
        forward!(A)
    end

    ans = 0
    for _ in 1:3
        shift!(A, 1000, :forward)
        ans += current(A).data * modifier
    end

    return ans
end


function main(data)

    A = circularlist(data)
    lookup = build_lookup_table(A)
    sort_list!(A, lookup)

    # forward!(A)
    # return A
    # println((1, data[1]))
    # println(lookup[(1, 1)])
    # jump!(A, lookup[(1, data[1])])  # reset head
    # jump!(A, lookup[1])  # TODO: investigate display here
    return grove_coordinates_sum!(A)
end

println(main(data))


function main2(data)
    key = 811589153
    data = [d * key for d in data]
    # println(data[1])
    A = circularlist(data)
    # println(A)
    lookup = build_lookup_table(A)
    # println(lookup)

    #=for _ in 1:10
        # println("k")
        for n in 1:length(data)
            w = lookup[n]
            jump!(A, w)  # jump to the nth node
            # println(current(A))
            delete!(A)  # delete current head from list
            shift!(A, mod(w.data, length(A)), sign(w.data) == 1 ? :forward : :backward)  # shift current head position
            insert!(A, w.data)
        end
        println(": $A")
        # println(A)
    end=#

    # return grove_coordinates_sum!(A)

    # println(lookup)
    for _ in 1:10
        # sort_list!(A, lookup, modifier = key)
        A = sort_list!(A, lookup)
        # forward!(A)
        # jump!(A, lookup[1])
        # println("!!!: $([a for a in A])")
    end
    # println(lookup)

    # println(A)
    return grove_coordinates_sum!(A)
    return grove_coordinates_sum!(A, modifier = key)
end

println(main2(data))

# 1697844508076 TOO LOW
# 2937952733860 TOO LOW
# 15371498557820 TOO HIGH
# 7736879395549 NOPE
# 15403150534787 NOPE
