# Constants for the chamber dimensions and the jet pattern
const CHAMBER_WIDTH = 7
const CHAMBER_HEIGHT = 10
const JET_PATTERN = ">>><<><>><<<>><>>><<<>>><<<><<<>><>><<>>"

# Function to check if a given position is inside the chamber
function is_inside_chamber(x, y)
    return (1 <= x <= CHAMBER_WIDTH) && (1 <= y <= CHAMBER_HEIGHT)
end

# Function to check if a given position is occupied by a stopped rock
function is_occupied(chamber, x, y)
    return chamber[y, x] == "#"
end

# Initialize the chamber to be empty
chamber = fill(".", CHAMBER_HEIGHT, CHAMBER_WIDTH)

# Initialize the falling rocks
rock_positions = [(CHAMBER_WIDTH + 1) ÷ 2, CHAMBER_HEIGHT + 1]

# Iterate through the jet pattern
for (i, jet) in enumerate(JET_PATTERN)
    # Update the positions of the falling rocks
    for j in 1:length(rock_positions)
        x, y = rock_positions[j]
        if jet == ">"
            # Push the rock to the right
            if is_inside_chamber(x + 1, y) && !is_occupied(chamber, x + 1, y)
                x += 1
            end
        elseif jet == "<"
            # Push the rock to the left
            if is_inside_chamber(x - 1, y) && !is_occupied(chamber, x - 1, y)
                x -= 1
            end
        end
        # Update the rock's vertical position
        if is_inside_chamber(x, y - 1) && !is_occupied(chamber, x, y - 1)
            y -= 1
        else
            # Stop the rock and mark it as stopped in the chamber
            chamber[y, x] = "#"
        end
        rock_positions[j] = (x, y)
    end

    # Remove stopped rocks from the list of falling rocks
    rock_positions = [pos for pos in rock_positions if !is_occupied(chamber, pos[1], pos[2])]

    # Start new rocks falling in empty columns
    for x in 1:CHAMBER_WIDTH
        if !is_occupied(chamber, x, CHAMBER_HEIGHT + 1)
            push!(rock_positions, (x, CHAMBER_HEIGHT + 1))
        end
    end
end

# Count the number of stopped rocks in the chamber
stopped_rocks = count(chamber .== "#")

# Print the final chamber and the number of stopped rocks
for row in chamber
    println(join(row))
end
println("Number of stopped rocks: ", stopped_rocks)
