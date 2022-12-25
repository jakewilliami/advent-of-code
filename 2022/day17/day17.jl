using AdventOfCode.Multidimensional

using DataStructures
using OrderedCollections

f = "data17.txt"
# f = "test.txt"

data = strip(read(f, String))

struct Rock
    alias::Symbol
    height::Int
    width::Int
    points::Vector{CartesianIndex{2}}  # top left is (1, 1)
end

const ROCKS = Rock[
    # Minus shape
    Rock(
        :minus, 1, 4,
        CartesianIndex{2}[
            CartesianIndex(1, 1),
            CartesianIndex(1, 2),
            CartesianIndex(1, 3),
            CartesianIndex(1, 4),
        ],
    ),

    # Plus shape
    # .#.
    # ###
    # .#.
    Rock(
        :plus, 3, 3,
        CartesianIndex{2}[
            CartesianIndex(1, 2),
            CartesianIndex(2, 1),
            CartesianIndex(2, 2),
            CartesianIndex(2, 3),
            CartesianIndex(3, 2),
        ],
    ),

    # Backwards L shape
    # ..#
    # ..#
    # ###
    Rock(
        :el, 3, 3,
        CartesianIndex{2}[
            CartesianIndex(1, 3),
            CartesianIndex(2, 3),
            CartesianIndex(3, 1),
            CartesianIndex(3, 2),
            CartesianIndex(3, 3),
        ],
    ),

    # I shape
    # #
    # #
    # #
    # #
    Rock(
        :aye, 4, 1,
        CartesianIndex{2}[
            CartesianIndex(1, 1),
            CartesianIndex(2, 1),
            CartesianIndex(3, 1),
            CartesianIndex(4, 1),
        ],
    ),

    # Square shape
    # ##
    # ##
    Rock(
        :square, 2, 2,
        CartesianIndex{2}[
            CartesianIndex(1, 1),
            CartesianIndex(1, 2),
            CartesianIndex(2, 1),
            CartesianIndex(2, 2),
        ]
    ),
]

lowest_point(r::Rock) = minimum(first(Tuple(i)) for i in r.points)

function highest_rock(chamber)
    i = findfirst(any, eachrow(chamber))
    #println("highest_rock: $i")
    isnothing(i) && return 1
    return i #size(chamber, 1) - i
end

function chamber_height(chamber)
    h = size(chamber, 1)
    # Subtract one to account for the floor;
    # Decrement again once to account for the first _empty_ row (we want the previous one from that)
    return findfirst(!any(chamber[h - i + 1, :]) for i in 1:h) - 1 - 1
end

function highest_occupied_row(chamber)
    return findfirst(all, eachrow(chamber))
end

# setindex!.(Ref(A), 1, ROCKS[i].points)

rock_obstructed(chamber::Matrix{Bool}, rock_indices::Stack{CartesianIndex{2}}, offset::CartesianIndex{2}) =
    any(chamber[p + offset] for p in rock_indices if (p + offset) ∉ rock_indices)

# Updates the rock position in the chamber matrix, and the rock indices stack
function update_rock_position!(chamber::Matrix{Bool}, rock_indices::Stack{CartesianIndex{2}}, offset::CartesianIndex{2})
    # Check that we can move the rock in the bounds of the matrix
    move_in_bounds = all(hasindex(chamber, p + offset) for p in rock_indices)
    move_in_bounds || return chamber

    # Check that there is not another rock in the way!
    # offset_indices = CartesianIndex{2}[p + offset for p in rock_indices]
    # move_allowed = all(!chamber[p + offset] for p in rock_indices if (p + offset) ∉ rock_indices)
    move_allowed = !rock_obstructed(chamber, rock_indices, offset)
    # move_allowed = all(!chamber[p + offset] for p in rock_indices if (p + offset) ∉ offset_indices)
    move_allowed || return chamber

    # Move the rock according to the offset
    # chamber[rock_indices] .= false
    # println(rock_indices)
    # setindex!.(Ref(chamber), false, rock_indices)

    current_rock_indices = deepcopy(rock_indices)
    empty!(rock_indices)
    while !isempty(current_rock_indices)
        p = pop!(current_rock_indices)
        chamber[p] = false
        p′ = p + offset
        # chamber[p′] = true
        push!(rock_indices, p′)
    end

    for p in rock_indices
        chamber[p] = true
        # chamber[p + offset] = true
    end
    return chamber
end

function draw(mat::Matrix{Bool})
    io = IOBuffer()
    diagram_started = false
    for (i, r) in enumerate(eachrow(mat))
        i == size(mat, 1) && continue  # ignore floor
        # ignore empty leading rows
        !any(r) && !diagram_started && continue
        diagram_started = true

        # draw diagram
        print(io, '|')
        for c in r
            print(io, c ? '#' : '.')#print(io, c ? '█' : ' ')
        end
        println(io, '|')
    end

    # draw floor
    print(io, '+')
    for _ in 1:size(mat, 2)
        print(io, '-')
    end
    println(io, '+')
    s = String(take!(io))
    println(s)
    return s
end

function main(data)
    chamber = zeros(Bool, 4000, 7)
    chamber[size(chamber, 1), :] .= true  # floor
    i, rᵢ = 0, 1
    rock_falling = false
    previous_rock_points = Stack{CartesianIndex{2}}()
    # prev_j = highest_rock(chamber)

    while rᵢ <= 2022 || rock_falling
        i  += 1
        j = highest_rock(chamber)
        ####println("i: $i (rᵢ = $rᵢ => mod1(rᵢ, length(ROCKS))), j: $j")
        # Alternate between falling and getting pushed by hot gas
        if !iszero(mod(i, 2))
            # rock is falling
            ####println("Rock is falling")
            if rock_falling
                # rock is still falling
                ####println("  Rock is falling")
                # if j == prev_j
                # if !rock_falling
                    # then rock has finished falling
                    # rock_falling = false
                    # println("  Rock has finished falling")
                # else
                    # println("  Rock is still falling; updating new position:")
                    # prev_j = j
                    # update rock position
                    update_rock_position!(chamber, previous_rock_points, CartesianIndex(1, 0))
                    # foreach(println, eachrow(chamber))
                    ####draw(chamber)
                # end
            else
                # prev_j = j
                # @label new_rock
                ####println("  Rock has only just begun falling: ")
                # a new rock needs to start falling
                # rᵢ += 1
                rock = ROCKS[mod1(rᵢ, length(ROCKS))]
                # println(findfirst(any, eachrow(chamber)))
                j = highest_rock(chamber)
                ####println("j: $j; rock: $rock")
                # rock begins falling 2 from left wall, and 3 above bottom
                # draw initial rock state
                empty!(previous_rock_points)
                for p in rock.points
                    p′ = p + CartesianIndex(j - rock.height - 3 - 1, 2)
                    # p′ = p + CartesianIndex(size(chamber, 1) - chamber_height(chamber) - rock.height - 3 - 1, 2)  # equivalent to above
                    ####println(p, " ", p′, " ($(size(chamber, 1)), $(chamber_height(chamber)))")
                    chamber[p′] = true
                    push!(previous_rock_points, p′)
                end
                rock_falling = true
                # foreach(println, eachrow(chamber))
                ####draw(chamber)
            end
        else
            #foreach(println, eachrow(chamber))
            # prev_j = j
            # rock is being pushed
            c = data[mod1(cld(i, 2), length(data))]
            ####println("Rock is being pushed: '$c':")
            k = c == '<' ? CartesianIndex(0, -1) : CartesianIndex(0, 1)
            # update rock position
            update_rock_position!(chamber, previous_rock_points, k)
            # foreach(println, eachrow(chamber))
            ####draw(chamber)
            # if prev_j == j
            # if highest_rock(chamber) == prev_j + 1
            # j = highest_rock(chamber)
            # q = lowest_point(rock)
            # Lowest point in the current rock
            q = minimum(first(Tuple(p)) for p in previous_rock_points)
            # The set of horizontal coordinates we should check isn't being obstructed
            xs = Set{Int}(last(Tuple(p)) for p in previous_rock_points)
            rock = ROCKS[mod1(rᵢ, length(ROCKS))]
            ####println("$previous_rock_points")
            # println("row $([first(Tuple(p)) + q for p in previous_rock_points])")
            # println("HERE: row $([first(Tuple(p)) + q for p in previous_rock_points]): $([chamber[p + CartesianIndex(q, 0)] for p in previous_rock_points])")
            ####println("HERE: row $([(q + rock.height, x) for x in xs]): $([chamber[q + rock.height, x] for x in xs])")
            # if any(chamber[q + rock.height, x] for x in xs)
            offset = CartesianIndex(1, 0)
            # if any(chamber[p + offset] for p in previous_rock_points if (p + offset) ∉ previous_rock_points)
            if rock_obstructed(chamber, previous_rock_points, CartesianIndex(1, 0))
            # if any(chamber[j + rock.height, :])
            # if any(chamber[j + 1, p] for p in 1:size(chamber, 2))
            # if any(chamber[highest_rock(chamber) + 1, :])  # If the next row is at all full,
                ####println("Rock has come to rest")
                ####println("OK: j + 1 = $(j + 1), highest rock = $(highest_rock(chamber))")
                rock_falling = false
                rᵢ += 1
                # i -= 1
                # @goto new_rock
            end
        end

        # if !rock_falling
            # prev_j = j
        # end

        # if  rᵢ >= 20 && !rock_falling
            # break
        # end
    end
    # println(chamber)
    draw(chamber)
    # println("rock: $rock")
    println("i: $i, rᵢ: $rᵢ, ")
    # println([size(chamber, 1) - rowᵢ] for rowᵢ in 1:size(chamber, 1)])
    return chamber_height(chamber)
    # return findfirst(!any(chamber[size(chamber, 1) - i, :]) for i in 1:size(chamber, 2))
    # return size(chamber, 1) - highest_rock(chamber)
end

# 3207 TOO HIGH
println(main(data))


### Part 2

# Shift rows in a matrix down by n places
function shift_down!(A::Matrix{T}, n::Int) where {T}
    A[(n + 1):end, :] = A[1:(end - n), :]
    A[1:n, :] .= zero(T)
    return A
end

# Does a matrix A have a repeating sequence of rows size n in it?
function repeating_sequence(A::Matrix{T}, n::Int) where {T}
    # take the top n rows from the matrix
    seq = view(A, (size(A, 1) - n):n, :)
    for i in 1:(size(A, 1) - 2n)
        seq′ = view(A, i:(i + n), :)
        if seq′ == seq
            return i:(i + n)
        end
    end

    return nothing
end


# TODO: optimisation: ignore all below row that is fulled up
# TODO: repeated patterns
function main2(f, n)
    data = strip(read(f, String))
    # As we have a looping input and a constant set of rocks that we iterate over,
    # we must have repeating cycles
    # cycle_length = length(data) * length(ROCKS)
    # chamber = zeros(Bool, 1500, 7)
    chamber = zeros(Bool, 100_000, 7)
    chamber[size(chamber, 1), :] .= true  # floor
    i, rᵢ = 0, 1
    rock_falling = false
    previous_rock_points = Stack{CartesianIndex{2}}()
    height_offset = 0
    drop_after = 70_000  # drop bottom rows after height of tower reaches this
    found_repeating, first_seq_range = false, nothing
    # keep track of pairs of jet instruction and rock shape
    # how many rocks stopped and height of tower when last say this pair
    pairs_seen = OrderedDict{Tuple{Int, Symbol}, Tuple{Int, Int}}()
    most_recently_seen_pairs = Vector{Tuple{Int, Symbol}}()

    # n = 2022
    # n = 1_000_000_000_000
    # n = 100_000
    while rᵢ <= n || rock_falling
        i += 1
        # i  = mod1(i + 1, length(data))
        j = highest_rock(chamber)

        # Every 1000 or so rows, remove the bottom 600 rows
        if ((size(chamber, 1) - j) ÷ drop_after) > 0
            k = drop_after ÷ 2

            # Shift entire matrix down
            shift_down!(chamber, k)

            # Recalculate highest rock
            j = highest_rock(chamber)

            # Update previous rock points
            # previous_rock_points = previous_rock_points .+ Ref(CartesianIndex(k, 0))
            rock_indices = deepcopy(previous_rock_points)
            empty!(previous_rock_points)
            while !isempty(rock_indices)
                p = pop!(rock_indices)
                push!(previous_rock_points, p + CartesianIndex(k, 0))
            end

            # add to height offset
            height_offset += k
            # draw(chamber)
        end

        # Alternate between falling and getting pushed by hot gas
        if !iszero(mod(i, 2))
            # rock is falling

            if rock_falling
                # rock is still falling
                # update rock position
                update_rock_position!(chamber, previous_rock_points, CartesianIndex(1, 0))
            else
                # a new rock needs to start falling
                rock = ROCKS[mod1(rᵢ, length(ROCKS))]
                j = highest_rock(chamber)

                # Check if we have reached a pattern; look at the last 25 for a pattern
                if rᵢ > 25
                    q = mod1(cld(i, 2), length(data))

                    if all(pairs_seen.vals[25 - mᵢ + 1] == most_recently_seen_pairs[mᵢ] for mᵢ in 1:25)

                        last_rᵢ, last_j = pairs_seen[(q, rock.alias)]
                        n_rocks_in_cycle = rᵢ - last_rᵢ
                        n_cycles_rem, rem_indiv = divrem(n - rᵢ, n_rocks_in_cycle)
                        height_offset = n_cycles_rem * n_rocks_in_cycle
                        i = n - rem_indiv
                        println("this_rᵢ: $rᵢ, last_rᵢ: $last_rᵢ, last_j: $last_j, n_cycles_rem: $n_cycles_rem, rem_indiv: $rem_indiv, height_offset: $height_offset, new i: $i")
                        return
                    end

                    @assert length(most_recently_seen_pairs) == 25 "$(length(most_recently_seen_pairs))"
                    popfirst!(most_recently_seen_pairs)
                end


                # rock begins falling 2 from left wall, and 3 above bottom
                # draw initial rock state
                empty!(previous_rock_points)
                for p in rock.points
                    p′ = p + CartesianIndex(j - rock.height - 3 - 1, 2)
                    # println(p, " ", p′)
                    chamber[p′] = true
                    push!(previous_rock_points, p′)
                end
                rock_falling = true
            end
        else
            # rock is being pushed
            q = mod1(cld(i, 2), length(data))
            c = data[q]
            # c = data[div(i, 2)]
            m = c == '<' ? CartesianIndex(0, -1) : CartesianIndex(0, 1)

            # update rock position
            update_rock_position!(chamber, previous_rock_points, m)

            # check if rock is at rest
            offset = CartesianIndex(1, 0)
            if rock_obstructed(chamber, previous_rock_points, CartesianIndex(1, 0))
                rock_falling = false
                rᵢ  += 1

                # Update rock/jet pattern pair seen
                j = highest_rock(chamber)
                rock = ROCKS[mod1(rᵢ, length(ROCKS))]
                push!(pairs_seen, (q, rock.alias) => (rᵢ, size(chamber, 1) - j))
                push!(most_recently_seen_pairs, (q, rock.alias))
            end

            # every so often, check if there have been any repeating patterns
            #=if !found_repeating && iszero(mod(rᵢ, 100length(ROCKS)))
                j = highest_rock(chamber)
                for pat_len in 1:(j ÷ 2)
                    s = repeating_sequence(chamber, pat_len)
                    if !isnothing(s)
                        println("REPEATING SEQUENCE!  $s")
                        found_repeating = true
                        first_seq_range = s
                        return s
                    end
                end
            end=#
        end
    end

    #=j = highest_rock(chamber)
    for pat_len in 1:(j ÷ 2)
        s = repeating_sequence(chamber, pat_len)
        if !isnothing(s)
            println("REPEATING SEQUENCE!  $s")
            found_repeating = true
            first_seq_range = s
            return s
        end
    end=#

    # return chamber

    return chamber_height(chamber) + height_offset
end

for n in (2022, 1_000_000_000_000)
    for f in ("test.txt", "data17.txt")
        print("Part 2 ($f, $n): ")
        println(main2(f, n))
    end
end

# println(main2(data))
