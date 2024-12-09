# We were given a long line as an input, containing digits.  Each digits
# represented disp space in alternating format:
#   The disk map uses a dense format to represent the layout of files and
#   free space on the disk.  The digits alternate between indicating the
#   length of a file and the length of free space.
#
# In part one, we had to move files from the right to the leftmost empty
# space, and then calculate some index-based checksum of the filesystem.
# In part two, we had to do the same, but could only move files in the
# blocks that they were originally in.
#
# For both parts, I actually simulated this with a vector rather than
# keeping track of positions and size (not immediately expanding the
# spaces) and doing index and range maths based on that.  It is slow to
# run, of course.  I was a bit slow to implement this for some reason;
# I did okay but not well.


### Parse Input ###

const FileOrFree = Union{Int, Nothing}
const FileSystem = Vector{FileOrFree}

function parse_input(input_file::String)
    L = strip(only(readlines(input_file)))
    return FileOrFree[parse(Int, c) for c in L]
end


### Part 1 ###

# Complicated but memory-efficient process of expanding the diskmap representation
function expand!(fs::FileSystem)
    # Step 1: collate file and free space information
    files = Int[fs[i] for i in 1:2:length(fs)]
    free_space = Int[fs[i] for i in 2:2:length(fs)]

    # Step 2: calculate offsets to be used later
    offsets = Dict{Int, Int}(0 => 0)
    for (i, (a, b)) in enumerate(zip(cumsum(files), cumsum(free_space)))
        offsets[i] = a + b - i
    end

    # Step 3: remove free space information from disk map
    deleteat!(fs, 2:2:length(fs))

    # Step 4: add free space
    for (i, (p, n)) in enumerate(zip(free_space, cumsum(free_space)))
        offset = n - p
        j = i + offset + 1
        splice!(fs, j:(j - 1), (nothing for _ in 1:p))
    end

    # Step 5: expand files
    for (i, n) in enumerate(files)
        id = i - 1
        j = i + offsets[id]
        fs[j] = id
        splice!(fs, j:(j - 1), (id for _ in 1:(n - 1)))
    end

    return fs
end

# Free space in the FileSystem is represented as nothing
isfree(x::FileOrFree) = isnothing(x)

function rstrip!(fs::FileSystem)
    i = findlast(!isfree, fs)
    if !isnothing(i)
        deleteat!(fs, (i + 1):lastindex(fs))
    end
    return fs
end

function left_align!(fs::FileSystem)
    while any(isfree, fs)
        rstrip!(fs)
        x = pop!(fs)
        i = findfirst(isfree, fs)
        @assert !isnothing(i)
        fs[i] = x
    end

    return rstrip!(fs)
end

function checksum(fs::FileSystem)
    sum(enumerate(fs)) do (i, x)
        isfree(x) && return 0
        x * (i - 1)
    end
end

function part1(fs::FileSystem)
    expand!(fs)
    left_align!(fs)
    return checksum(fs)
end


### Part 2 ###

function findfirst_viable_block(fs::FileSystem, block_size::Int)
    for i in 1:(length(fs) - block_size)
        all(isnothing, fs[i:(i + block_size - 1)]) && return i
    end
end

function last_nonempty(fs::FileSystem)
    i = findlast(!isfree, fs)
    if !isnothing(i)
        return fs[i]
    end
end

function find_block(fs::FileSystem, id::Int)
    indices = findall(==(id), fs)
    @assert all(indices[i - 1] == indices[i] - 1 for i in 2:length(indices))
    isempty(indices) && return 0:-1
    return UnitRange{Int}(extrema(indices)...)
end

function left_align_in_blocks!(fs::FileSystem)
    for id in last_nonempty(fs):-1:0
        file_block = find_block(fs, id)
        n = length(file_block)

        # Find a chunk of free space that would fit the current block
        k = findfirst_viable_block(fs, n)
        if !isnothing(k)
            # We shouldn't move anything further to the right
            # than it presently is
            k > last(file_block) && continue

            # copyto!(dest, do, src, so, N)
            # Copy N elements from collection src starting at the linear
            # index `so`, to array dest starting at the index `do`
            copyto!(fs, k, fs, first(file_block), n)

            # Free the space we moved the block from
            splice!(fs, file_block, (nothing for _ in file_block))
        end
    end

    return fs
end

function part2(fs::FileSystem)
    expand!(fs)
    left_align_in_blocks!(fs)
    checksum(fs)
end


### Main ###

function main()
    data = parse_input("data09.txt")

    # Part 1
    part1_solution = part1(deepcopy(data))
    @assert part1_solution == 6463499258318
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(deepcopy(data))
    @assert part2_solution == 6493634986625
    println("Part 2: $part2_solution")
end

main()
