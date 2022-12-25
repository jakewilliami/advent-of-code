using AdventOfCode.Multidimensional

using DataStructures

f = "data24.txt"
# f = "test.txt"
# f = "large.txt"

function parse_input(data_file::String)
    return readlines_into_char_matrix(data_file)
end

M = parse_input(f)

# println(M)

const DIRECTIONS = Dict{Char, CartesianIndex{2}}(
    '>' => CartesianIndex(0, 1),
    'v' => CartesianIndex(1, 0),
    '<' => CartesianIndex(0, -1),
    '^' => CartesianIndex(-1, 0),
)


# TODO: add these to multidimensional API
function move_within_bounds(i::CartesianIndex{N}, dir::CartesianIndex{N}, M::Array{T, N}) where {T, N}
     return CartesianIndex(map(mod1, Tuple(i + dir), size(M)))
end

# TODO: ibid.
function next_idx(i::CartesianIndex{N}, dir::CartesianIndex{N}, M::Array{T, N}) where {T, N}
    i = move_within_bounds(i, dir, M)
    while M[i] == '#'
        i = move_within_bounds(i, dir, M)
    end
    return i
end

function next_idx(i::CartesianIndex{N}, dir::CartesianIndex{N}, M::Array{T, N}, n::Int) where {T, N}
    for _ in 1:n
        i = next_idx(i, dir, M)
    end
    return i
end



# function process_blizard!(M, blizzard_indices)
function process_blizzard!(blizzard_indices, M)
    for (i, (j, c)) in enumerate(blizzard_indices)
        # k = j + DIRECTIONS[c]
        # if k ∈ wall_indices
        # k = next_idx(j, DIRECTIONS[c], M)
        # println(i, " ", j, " ", DIRECTIONS[c])
        blizzard_indices[i] = (next_idx(j, DIRECTIONS[c], M), c)
    end
    return blizzard_indices
end

process_blizzard(blizzard_indices, M) = process_blizzard!(copy(blizzard_indices), M)

mult_dir(dir::CartesianIndex{2}, n::Int) = CartesianIndex(map(*, Tuple(dir), n))

function main(M)
    # M = deepcopy(M)
    start_row_i = findfirst(==('.'), M[1, :])
    @assert !isnothing(start_row_i)
    start_i = CartesianIndex(1, start_row_i)
    goal_row_i = findfirst(==('.'), M[end, :])
    goal_i = CartesianIndex(size(M, 1), goal_row_i)
    # map(println ∘ join, eachrow(M))
    # println("-------------")

    # blizzard_indices = Tuple{CartesianIndex{2}, Char}[(i, M[i]) for i in CartesianIndices(M) if M[i] ∉ ('#', '.')]
    blizzard_indices = Tuple{CartesianIndex{2}, Char}[(i, M[i]) for i in CartesianIndices(M) if M[i] ∉ ('#', '.')]
    # println(blizzard_indices)
    wall_indices = CartesianIndex{2}[i for i in CartesianIndices(M) if M[i] == '#']
    # process_blizzard!(blizzard_indices, M)

    # Find number of possible positions of blizzard
    initial_blizzard_indices = copy(blizzard_indices)
    process_blizzard!(blizzard_indices, M)
    n_blizzard_positions = 1
    while blizzard_indices != initial_blizzard_indices
        process_blizzard!(blizzard_indices, M)
        n_blizzard_positions += 1
    end
    println("Total blizzard positions: $n_blizzard_positions")
    #=println("Calculating blizzard positions")

    all_blizzard_indices = Vector{Tuple{CartesianIndex{2}, Char}}[blizzard_indices, process_blizzard(blizzard_indices, M)]
    while first(all_blizzard_indices) != last(all_blizzard_indices)
        push!(all_blizzard_indices, process_blizzard(blizzard_indices, M))
    end
    n_blizzard_positions = length(all_blizzard_indices)
    return n_blizzard_positions=#

    println("Starting BFS")
    # return
    # TODO: only keep track of offset of direction, not


    # Find path (BFS)
    # seen = Set{CartesianIndex{2}}()
    # seen = Vector{CartesianIndex{2}}()
    # Q = Queue{Tuple{CartesianIndex{2}, Int, Vector{Tuple{CartesianIndex{2}, Char}}}}()
    # enqueue!(Q, (start_i, 1, blizzard_indices))
    Q = Queue{Tuple{CartesianIndex{2}, Int, Int}}()
    enqueue!(Q, (start_i, 1, 1))

    while !isempty(Q)
        # println(Q)
        i, n, vᵢ = dequeue!(Q)
        # println(i, " ", n, " ", vᵢ, " ", length(Q))
        # i ∈ seen && i ≠ last(seen) && continue
        # i ∈ seen || push!(seen, i)

        # Check if we have reached our goal
        if i == goal_i
            return n
        end

        # Process blizzard indices
        # v′ = process_blizzard(v, M)
        # println("blizzard positions: $v")
        n′ = n + 1
        vᵢ′ = mod1(vᵢ + 1, n_blizzard_positions)
        # vᵢ′ = vᵢ + 1

        # Can also wait
        # println("Q: $Q")
        enqueue!(Q, (i, n′, vᵢ′))

        # Check valid surroundings
        for d in cardinal_directions(2)
            j = i + d
            if hasindex(M, j) && j ∉ wall_indices && all(j ≠ next_idx(k, DIRECTIONS[c], M, vᵢ) for (k, c) in initial_blizzard_indices)  # && j ∉ seen
            # if hasindex(M, j) && j ∉ wall_indices && all(j ≠ k for (k, _c) in all_blizzard_indices[vᵢ])  # && j ∉ seen
            # if hasindex(M, j) && j ∉ wall_indices && all(j ≠ k for (k, _c) in v′)  # && j ∉ seen
            # if hasindex(M, j) && j ∉ wall_indices && j ∉ first.(v′)#all(j ≠ k for (k, _c) in v)  # && j ∉ seen
                # println("    moving to $j")
                # enqueue!(Q, (j, n + 1, v′))
                enqueue!(Q, (j, n′, vᵢ′))
            end
        end
    end

    # process_blizzard!(blizzard_indices, M)
    # println(blizzard_indices)
    # map(println ∘ join, eachrow(M))
    # println("-------------")
end

println(main(M))
