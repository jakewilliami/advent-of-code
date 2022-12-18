using AdventOfCode.Multidimensional

using MultidimensionalTools

f = "data18.txt"
# f = "test.txt"

data = CartesianIndex{3}[CartesianIndex(Tuple(parse.(Int, split(l, ',')))) + CartesianIndex{3}() for l in eachline(f)]
# data = [CartesianIndex(1, 1, 1), CartesianIndex(2, 1, 1)]

# println(data)

function main(data)
    M = zeros(Bool, (last(Tuple(i)) for i in extrema_indices(Tuple.(data)))...)
    for i in data
        M[i] = true
    end
    # return M
    res = 0
    for i in CartesianIndices(M)
        # println("Checking $i ($(M[i]))")
        M[i] || continue
        # sum(map(abs, Tuple(i))) != dim
        for d in cartesian_directions(ndims(M))
            sum(map(abs, Tuple(d))) == 1 || continue
            j = i + d
            # println("    Checking $j ($(hasindex(M, j)), $(a)))")
            if (!hasindex(M, j) || !M[j])
                res += 1
                # push!(counted, j)
            end
            # hasindex(M, j) || continue
            # M[j] || (res += 1)
        end
    end
    return res
end

println(main(data))

des(i) = (d for d in cartesian_directions(i) if sum(map(abs, Tuple(d))) == 1)

adj(M, i) = (M[i + d] for d in des(ndims(M)) if hasindex(M, i + d))


function flood_fill!(M, i, visited)
    i ∉ visited || return
    # hasindex(M, i) || return
    M[i] == 0 || return

    for d in des(ndims(M))
        j = i + d
        hasindex(M, j) || continue
        M[j] = 2
        flood_fill!(M, j, visited)
        push!(visited, j)
    end
end


# In direction d of magintude m
in_dir(d::CartesianIndex{N}, m::CartesianIndex{N}) where {N} = CartesianIndex(map(*, Tuple(d), Tuple(m)))
Base.abs(i::CartesianIndex{N}) where {N} = CartesianIndex(map(abs, Tuple(i)))
Base.inv(i::CartesianIndex{N}) where {N} = CartesianIndex((iszero(j) ? 1 : 0 for j in Tuple(i))...)
# Base.(*)(i::CartesianIndex{N}, j::CartesianIndex{N}) where {N} = CartesianIndex(map(*, Tuple(i), Tuple(j)))
midxs(i, j) = CartesianIndex(map(*, Tuple(i), Tuple(j)))
des2(i) = (d for d in des(i) if all(map(>=(0), Tuple(d))))

function is_internal(M, i::CartesianIndex{N}) where {N}
    # if it is on the edge, it is not internal
    any(!hasindex(M, i + d) for d in des(ndims(M))) && return false  # TODO: can do this nicer with maths

    ## TODO: there is an edge case where this isn't good enough.  Once possibility is to make a queue and keep finding adjacent empty, and run this functio

    #=all_internal = Bool[false for _ in 1:ndims(M)]
    for (j, a) in enumerate(axes(M))
        this_axis_internal = sum(for k in a if k != Tuple(i)[a]) > 2
        for j in a
        end
    end
    return all(all_internal)=#

    # r, c, d = Tuple(i)
    # R, C, D = size(M)
    ####println("  $i")
    s = CartesianIndex(size(M))
    all_internal = Bool[false for _ in 1:ndims(M)]
    for (dᵢ, d) in enumerate(des2(ndims(M)))
        # d == CartesianIndex(0, 0, 1) && continue
        # i_start = max(abs(d), CartesianIndex{N}())
        # i_start = midxs(abs(d), i) + midxs(inv(abs(d)), i)
        i_start = midxs(abs(d), CartesianIndex{N}()) + midxs(inv(abs(d)), i)
        a = M[i_start:(i - abs(d))]
        # i_end = in_dir(d, s)
        i_end = midxs(inv(d), i) + midxs(s, d)
        b = M[(i + abs(d)):i_end]
        ####println("    $i_start, $i_end")
        ####println("    $(i_start:(i - abs(d))), $((i + abs(d)):i_end)")
        # println(a)
        # println(b)
        if sum(a) > 0 && sum(b) > 0
            # return true
            all_internal[dᵢ] = true
        end
    end

    return all(all_internal)

    return false
end


function main2(data)
    M = zeros(Bool, (last(Tuple(i)) for i in extrema_indices(Tuple.(data)))...)
    for i in data
        M[i] = true
    end
    # M2 = Int8.(M)
    # flood_fill!(M2, CartesianIndex{3}(), Set{CartesianIndex{3}}())
    # return M2


    #=sa = 0
    for i in axes(M, 1), j in axes(M, 2), k in axes(M, 3)
        sa += 4
        if i > 1
            sa -= 2 * M[i - 1, j, k]
        end
        if j > 1
            sa -= 2 * M[i, j - 1, k]
        end
        if k > 1
            sa -= 2 * M[i, j, k - 1]
        end
    end
    return sa=#
    seen = Set{CartesianIndex{ndims(M)}}()


    # return M
    res = 0
    for i in CartesianIndices(M)
        ####println(i)
        M[i] || continue
        # all(hasindex(M, i + d) && M[i + d] for d in des(ndims(M))) && continue
        # all(a for a in adj(M, i)) && continue
        #=if all(a for a in adj(M, i)) && sum(1 for _ in adj(M, i)) == n_cardinal_adjacencies(ndims(M))
            res += 1#n_cardinal_adjacencies(ndims(M))
        end
        continue=#

        #=not_trapped = false
        for d in des(ndims(M))
            j = i + d
            if !hasindex(M, j)
                not_trapped = true
                continue
            end
            if !M[j]
                not_trapped = true
                continue
            end
        end=#
        # not_trapped || continue
        for d in des(ndims(M))
            j = i + d
            # is_internal(M, j) && (println("      $j is internal"); continue)


            #=if !hasindex(M, j)
                res += 1
                continue
            end=#
            # all(hasindex(M, j + d) && M[j + d] for d in des(ndims(M))) && continue
            # all(a for a in adj(M, j)) && continue
            # indices = extrema_indices(Tuple.(data))
            # if all are properly in the matrix
            #=if all(1 < k < size(M, s) for (s, k) in enumerate(Tuple(j)))
                all()
            end=#
            j ∈ seen && continue
            internal = is_internal(M, j)
            # Count this edge is if it an outer edge, or if is is empty space (i.e., false)
            count_this_side = !hasindex(M, j) || !M[j]
            if internal && count_this_side
                println("      $j is internal (count this side: $count_this_side)")
            end
            internal && push!(seen, j)
            internal && continue
            if count_this_side#!hasindex(M, j) || !M[j]
                # println("$j counts for one")
            # if !M[j]
                res += 1
            end
        end
    end
    return res
    # res2 =
    return main(data) - res
end

println(main2(data))

# NOT 3324
# NOT 288
# NOT 2003; TOO LOW
# NOT 2029
