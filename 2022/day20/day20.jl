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

# e.g., norm(270, 180) -> -90
function norm(a::Int, b::Int)
    a ∈ -b:b && return a
    c = 2b
    return a - c * fld(a + b, c)
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
        # i = mod(abs(w.data) * modifier, length(A))  # - 1
        # i = norm(w.data * modifier, div(length(A) - 1, 2))
        # i = mod(w.data * modifier, length(A))
        # i = mod(abs(w.data) * modifier, length(A)) * sign(w.data)
        # i = mod(abs(w.data * modifier), length(A)) * sign(w.data)
        d = big(w.data)
        # i = Int(mod(abs(d * modifier), length(A))) * sign(d)
        # i = Int(mod(abs(d) * modifier, length(A))) * Int(sign(d))
        # i = Int(mod(d * modifier, length(A)))
        # i = Int(mod(abs(d * modifier), length(A))) * Int(sign(d))
        # i = mod(abs(w.data * modifier), length(A)) * sign(w.data)
        # i = mod(w.data * modifier, length(A))
        # i = Int(mod(d * modifier, length(A)))
        # i = mod(w.data * modifier, length(A)) * sign(w.data)
        i = mod(w.data, length(A))
        # i = w.data * modifier
        # shift!(A, i, sign(w.data) == 1 ? :forward : :backward)  # shift current head position
        shift!(A, i)  # shift current head position
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
    # forward!(A)

    ans = 0
    for _ in 1:3
        i = 1000
        # i = norm(1000, length(A) ÷ 2)
        shift!(A, 1000)
        # ans += current(A).data * modifier
        ans += current(A).data
    end

    return ans
end


function main(data)

    A = circularlist(data)
    lookup = build_lookup_table(A)
    sort_list!(A, lookup)

    # println(A)

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
    # mag, key = divrem(811589153, length(data))
    # key = 811589153 % length(data)
    data = [d * key for d in data]
    # println(data[1])
    A = circularlist(data; capacity = length(data))
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
        jump!(A, lookup[1])
        # println("!!!: $([a for a in A])")
    end

    # println(lookup)
    # while !iszero(current(A).data)
        # forward!(A)
    # end

    println(A)
    # return A
    return grove_coordinates_sum!(A)
    return grove_coordinates_sum!(A, modifier = key)
end

println(main2(data))


# 1697844508076 TOO LOW
# 2937952733860 TOO LOW
# 15371498557820 TOO HIGH
# 7736879395549 NOPE
# 15403150534787 NOPE
# 16524766744233 NOPE
# 1438947568269 NOPE
# 7274410435517330557

function main()
end

# A = Deque{Int}(6); push!.(Ref(A), (1, 2, -3, 3, -2, 0, 4)); A
#=using DataStructures
function sort_list!(A, lookup; modifier = 1)


    for n in 1:length(A)
        w = lookup[n]
        jump!(A, w)  # jump to the nth node
        delete!(A)  # delete current head from list
        i = mod(w.data * modifier, length(A))
        shift!(A, i)  # shift current head position
        insert!(A, w.data)
    end

    return A
end
function mix!(A::CircularDeque{Tuple{Int, Int}})
    for i in 1:length(A)
        while A[1][1] != i

        end
    end
end
function main_deque(data)
    A = CircularDeque{Tuple{Int, Int}}(length(data))
    push!.(Ref(A), collect(enumerate(data)))
    println(A)


end
=#
