using DataStructures

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
    return i
end

# Updates the rock position in the chamber matrix, and the rock indices stack
function update_rock_position!(chamber::Matrix{Bool}, rock_indices::Stack{CartesianIndex{2}}, offset::CartesianIndex{2})
    current_rock_indices = deepcopy(rock_indices)

    # Check that we can move the rock in the bounds of the matrix
    move_in_bounds = all(hasindex(chamber, p + offset) for p in rock_indices)
    move_in_bounds || return chamber

    # Check that there is not another rock in the way!
    offset_indices = CartesianIndex{2}[p + offset for p in rock_indices]
    move_allowed = all(!chamber[p + offset] for p in rock_indices if (p + offset) ∉ rock_indices)
    move_allowed || return chamber

    empty!(rock_indices)
    while !isempty(current_rock_indices)
        p = pop!(current_rock_indices)
        chamber[p] = false
        p′ = p + offset
        push!(rock_indices, p′)
    end
    for p in rock_indices
        chamber[p] = true
    end
    return chamber
end

function main(data)
    chamber = zeros(Bool, 4000, 7)
    chamber[size(chamber, 1), :] .= true  # floor
    i = 0
    rᵢ = 0
    rock_falling = false
    rock = nothing
    previous_rock_points = Stack{CartesianIndex{2}}()
    prev_j = highest_rock(chamber)

    while true
        i  += 1
        j = highest_rock(chamber)
        # Alternate between falling and getting pushed by hot gas
        if !iszero(mod(i, 2))
            # rock is falling
            if rock_falling
                if !rock_falling
                    # then rock has finished falling
                    rock_falling = false
                else
                    # otherwise, rock is still falling
                    # update rock position
                    update_rock_position!(chamber, previous_rock_points, CartesianIndex(1, 0))
                end
            else
                # a new rock needs to start falling
                rᵢ += 1
                rock = ROCKS[mod1(rᵢ, length(ROCKS))]
                # rock begins falling 2 from left wall, and 3 above bottom
                # draw initial rock state
                empty!(previous_rock_points)
                for p in rock.points
                    p′ = p + CartesianIndex(j - rock.height - 4, 2)
                    ###println(p, " ", p′)
                    chamber[p′] = true
                    push!(previous_rock_points, p′)
                end
                rock_falling = true
            end
        else
            # rock is being pushed
            c = data[mod1(cld(i, 2), length(data))]
            k = c == '<' ? CartesianIndex(0, -1) : CartesianIndex(0, 1)
            # update rock position
            update_rock_position!(chamber, previous_rock_points, k)

            # Check if rock has finished falling
            q = minimum(first(Tuple(p)) for p in previous_rock_points)
            xs = Set{Int}(last(Tuple(p)) for p in previous_rock_points)
            if any(chamber[q + rock.height, x] for x in xs)
                rock_falling = false
            end
        end

        if rᵢ >= 2022 && !rock_falling
            break
        end
    end

    # Return the first empty row from the bottom of the array
    # Subtract one to account for the floor, and another to account for going back one from the empty row
    return findfirst(!any(chamber[size(chamber, 1) - rowᵢ + 1, :]) for rowᵢ in 1:size(chamber, 1)) - 2
end

println(main(data))
