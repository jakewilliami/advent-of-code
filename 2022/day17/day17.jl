using AdventOfCode.Multidimensional

using DataStructures

f = "data17.txt"
f = "test.txt"

data = strip(read(f, String))

struct Rock
    alias::String
    height::Int
    width::Int
    points::Vector{CartesianIndex{2}}  # top left is (1, 1)
end

const ROCKS = Rock[
    # Minus shape
    Rock(
        "minus", 1, 4,
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
        "plus", 3, 3,
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
        "el", 3, 3,
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
        "aye", 4, 1,
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
        "square", 2, 2,
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
    w = size(chamber, 1)
    # Subtract one to account for the floor;
    # Decrement again once to account for the first _empty_ row (we want the previous one from that)
    return findfirst(!any(chamber[w - i + 1, :]) for i in 1:w) - 1 - 1
end

# setindex!.(Ref(A), 1, ROCKS[i].points)

# Updates the rock position in the chamber matrix, and the rock indices stack
function update_rock_position!(chamber::Matrix{Bool}, rock_indices::Stack{CartesianIndex{2}}, offset::CartesianIndex{2})
    # Check that we can move the rock in the bounds of the matrix
    move_in_bounds = all(hasindex(chamber, p + offset) for p in rock_indices)
    move_in_bounds || return chamber

    # Check that there is not another rock in the way!
    # offset_indices = CartesianIndex{2}[p + offset for p in rock_indices]
    move_allowed = all(!chamber[p + offset] for p in rock_indices if (p + offset) ∉ rock_indices)
    # move_allowed = all(!chamber[p + offset] for p in rock_indices if (p + offset) ∉ offset_indices)
    move_allowed || return chamber

    # Move the rock according to the offset
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
    end
    return chamber
end

function draw(mat::Matrix{Bool})
    io = IOBuffer()
    for (i, r) in enumerate(eachrow(mat))
        i == size(mat, 1) && continue  # ignore floor
        print(io, '|')
        for c in r
            print(io, c ? '#' : '.')#print(io, c ? '█' : ' ')
        end
        println(io, '|')
    end
    print(io, '+')
    for _ in 1:size(mat, 2)
        print(io, '-')
    end
    println(io, '+')
    s = String(take!(io))
    println(s)
    return s
end

# TODO: optimisation: ignore all below row that is fulled up
function main(data)
    chamber = zeros(Bool, 30, 7)
    chamber[size(chamber, 1), :] .= true  # floor
    i, rᵢ = 0, 1
    rock_falling = false
    previous_rock_points = Stack{CartesianIndex{2}}()
    # prev_j = highest_rock(chamber)

    while true
        i  += 1
        j = highest_rock(chamber)
        ;;println("i: $i (rᵢ = $rᵢ => mod1(rᵢ, length(ROCKS))), j: $j")
        # Alternate between falling and getting pushed by hot gas
        if !iszero(mod(i, 2))
            # rock is falling
            ;;println("Rock is falling")
            if rock_falling
                # rock is still falling
                println("  Rock is falling")
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
                    ;;draw(chamber)
                # end
            else
                # prev_j = j
                # @label new_rock
                ;;println("  Rock has only just begun falling: ")
                # a new rock needs to start falling
                # rᵢ += 1
                rock = ROCKS[mod1(rᵢ, length(ROCKS))]
                # println(findfirst(any, eachrow(chamber)))
                j = highest_rock(chamber)
                ;;println("j: $j; rock: $rock")
                # rock begins falling 2 from left wall, and 3 above bottom
                # draw initial rock state
                empty!(previous_rock_points)
                for p in rock.points
                    p′ = p + CartesianIndex(j - rock.height - 3 - 1, 2)
                    ###println(p, " ", p′)
                    chamber[p′] = true
                    push!(previous_rock_points, p′)
                end
                rock_falling = true
                # foreach(println, eachrow(chamber))
                ;;draw(chamber)
            end
        else
            #foreach(println, eachrow(chamber))
            # prev_j = j
            # rock is being pushed
            c = data[mod1(cld(i, 2), length(data))]
            ;;println("Rock is being pushed: '$c':")
            k = c == '<' ? CartesianIndex(0, -1) : CartesianIndex(0, 1)
            # update rock position
            update_rock_position!(chamber, previous_rock_points, k)
            # foreach(println, eachrow(chamber))
            ;;draw(chamber)
            # if prev_j == j
            # if highest_rock(chamber) == prev_j + 1
            # j = highest_rock(chamber)
            # q = lowest_point(rock)
            q = minimum(first(Tuple(p)) for p in previous_rock_points)
            xs = Set{Int}(last(Tuple(p)) for p in previous_rock_points)
            rock = ROCKS[mod1(rᵢ, length(ROCKS))]
            ;;println("$previous_rock_points")
            # println("row $([first(Tuple(p)) + q for p in previous_rock_points])")
            # println("HERE: row $([first(Tuple(p)) + q for p in previous_rock_points]): $([chamber[p + CartesianIndex(q, 0)] for p in previous_rock_points])")
            ;;println("HERE: row $([(q + rock.height, x) for x in xs]): $([chamber[q + rock.height, x] for x in xs])")
            if any(chamber[q + rock.height, x] for x in xs)
            # if any(chamber[j + rock.height, :])
            # if any(chamber[j + 1, p] for p in 1:size(chamber, 2))
            # if any(chamber[highest_rock(chamber) + 1, :])  # If the next row is at all full,
                ;;println("Rock has come to rest")
                ;;println("OK: j + 1 = $(j + 1), highest rock = $(highest_rock(chamber))")
                rock_falling = false
                rᵢ += 1
                # i -= 1
                # @goto new_rock
            end
        end

        # if !rock_falling
            # prev_j = j
        # end

        if rᵢ >= 14 && !rock_falling
            break
        end
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

println(main(data))
