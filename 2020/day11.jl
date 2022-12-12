using AdventOfCode.Multidimensional
import AdventOfCode.Multidimensional: _lines_into_matrix

const datafile = joinpath(@__DIR__, "inputs", "data11.txt")

tryindices(M::Matrix{T}, inds::NTuple{N, Int}...) where {T, N} =
    Union{T, Nothing}[tryindex(M, CartesianIndex(i)) for i in inds]

get_adjacencies(M::Matrix{T}, inds::CartesianIndex{N}...) where {T, N} =
    T[M[i] for i in inds if hasindex(M, i)]

function adjacencies(M::Matrix{T}, idx::NTuple{N, Int}) where {T, N}
    D = cartesian_directions(N)
    i = CartesianIndex(idx)
    A = CartesianIndex{N}[i + d for d in D]
    return T[k for k in get_adjacencies(M, A...)]
end

function n_adjacent_to(M::Matrix{T}, idx::NTuple{2, Int}, adj_elem::T) where T
    return length(T[i for i in adjacencies(M, idx) if i == adj_elem])
end

function mutate_seats!(seat_layout::Vector{String})
    no_seat, empty_seat, occupied_seat = '.', 'L', '#'
    seat_layout = _lines_into_matrix(seat_layout)
    seat_layout_clone = copy(seat_layout)

    for row_idx in axes(seat_layout_clone, 1)
        row = seat_layout_clone[row_idx, :]
        original_row = copy(row)

        for seat_idx in axes(seat_layout_clone, 2)
            seat = original_row[seat_idx]

            if seat == empty_seat && all(s -> s ≠ occupied_seat, adjacencies(seat_layout_clone, (row_idx, seat_idx)))
                row[seat_idx] = occupied_seat
            elseif seat == occupied_seat && n_adjacent_to(seat_layout_clone, (row_idx, seat_idx), occupied_seat) ≥ 4
                row[seat_idx] = empty_seat
            end
        end

        seat_layout[row_idx, :] = row
    end

    return String[join(i) for i in eachrow(seat_layout)]
end

function stabilise_chaos(seat_layout::Vector{String}, mutating_funct::Function)
    while true
        old_seat_layout = copy(seat_layout)
        seat_layout = mutating_funct(seat_layout)

        if old_seat_layout == seat_layout
            return seat_layout
        end
    end
end

function Base.count(count_by::Char, seat_layout::Vector{String}, mutating_funct::Function)
    return count(==(count_by), reduce(vcat, permutedims(collect(s)) for s in stabilise_chaos(seat_layout, mutating_funct)))
end

res1 = count('#', readlines(datafile), mutate_seats!)
@assert res1 == 2321
println(res1)

#=
BenchmarkTools.Trial:
  memory estimate:  1.90 GiB
  allocs estimate:  36545622
  --------------
  minimum time:     5.186 s (3.29% GC)
  median time:      5.186 s (3.29% GC)
  mean time:        5.186 s (3.29% GC)
  maximum time:     5.186 s (3.29% GC)
  --------------
  samples:          1
  evals/sample:     1
=#

function global_adjacencies(M::Matrix{T}, idx::NTuple{N, Int}, adj_elem::T) where {T, N}
    no_seat, empty_seat, occupied_seat = '.', 'L', '#'
    adjacent_indices, 𝟎 = Vector{CartesianIndex{N}}(), 𝟘(N)
    directional_shifts = cartesian_directions(N)
    n_adjacent, adjacent_count = n_adjacencies(ndims(M)), 0
    i = CartesianIndex(idx)

    while adjacent_count < n_adjacent
        for directional_shift in directional_shifts
            adj_index = i + directional_shift
            while true

                if !hasindex(M, adj_index)
                    n_adjacent -= 1
                    break
                end

                if M[adj_index] ≠ adj_elem
                    adjacent_count += 1
                    push!(adjacent_indices, adj_index)
                    break
                else
                    adj_index += directional_shift
                end
            end
        end
    end

    return T[M[i] for i in adjacent_indices]
end

function global_n_adjacent_to(M::Matrix{T}, idx::NTuple{N, Int}, ignored_elem::T, adj_elem::T) where {T, N}
    return length(T[i for i in global_adjacencies(M, idx, ignored_elem) if i == adj_elem])
end

function mutate_seats_again!(seat_layout::Vector{String})
    no_seat, empty_seat, occupied_seat = '.', 'L', '#'
    seat_layout = _lines_into_matrix(seat_layout)
    seat_layout_clone = copy(seat_layout)

    for row_idx in axes(seat_layout_clone, 1)
        row = seat_layout_clone[row_idx, :]
        original_row = copy(row)

        for seat_idx in axes(seat_layout_clone, 2)
            seat = original_row[seat_idx]

            if seat == empty_seat && all(s -> s ≠ occupied_seat, global_adjacencies(seat_layout_clone, (row_idx, seat_idx), no_seat))
                row[seat_idx] = occupied_seat
            elseif seat == occupied_seat && global_n_adjacent_to(seat_layout_clone, (row_idx, seat_idx), no_seat, occupied_seat) ≥ 5
                row[seat_idx] = empty_seat
            end
        end

        seat_layout[row_idx, :] = row
    end

    return String[join(i) for i in eachrow(seat_layout)]
end

res2 = count('#', readlines(datafile), mutate_seats_again!)
@assert res2 == 2102
println(res2)

#=
BenchmarkTools.Trial:
  memory estimate:  3.99 GiB
  allocs estimate:  89161036
  --------------
  minimum time:     12.434 s (3.03% GC)
  median time:      12.434 s (3.03% GC)
  mean time:        12.434 s (3.03% GC)
  maximum time:     12.434 s (3.03% GC)
  --------------
  samples:          1
  evals/sample:     1
=#
