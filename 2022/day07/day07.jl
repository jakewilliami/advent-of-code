# Today's problem was really interesting!  We were essentially given a terminal output of
# cd-ing and ls-ing, and we had to construct a file system from there.  It was really good
# practice for something I sometimes struggle with: recursion.  Indeed, the hardest part was
# actually parsing the input.
#
# Part 1 required us to find the total summed size of all directories with total size of at
# most 100,000 bytes.
#
# In part 2, we were to find the smallest directory that would free up enough space to use
# the file system.  (The file system has a size of 70,000,000 bytes, and you need unused
# space of at least 30,000,000).  As mentioned, the problems themselves were trivial once
# the input was parsed.
#
# Both parts could actually have been done without using recursion; we only actually care
# about the size of the directory and all children (files or subdirectories), so we could
# store all of this information in a simple String => Int map.  However, as I say, I needed
# some practice with recursion, and this was fun, I guess.


### Parse input

abstract type FileSystemObject end

struct File <: FileSystemObject
    sz::Int
    name::AbstractString
end

struct Dir <: FileSystemObject
    name::AbstractString
    children::Dict{AbstractString, FileSystemObject}
end

function add_file!(dir::Dir, f::File)
    return dir.children[f.name] = f
end

function add_dir!(dir::Dir, new_dir_name::S) where {S <: AbstractString}
    dir.children[new_dir_name] = Dir(new_dir_name, Dict{AbstractString, FileSystemObject}())
    return dir.children[new_dir_name]
end

function add_dir!(fs::Dir, keys::Vector{S}) where {S <: AbstractString}
    if length(keys) == 1
        add_dir!(fs, keys[1])
    else
        if fs.name == "/" && keys[1] == "/"
            return add_dir!(fs, keys[2:end])
        end

        inner_dir = get(fs.children, keys[1], Dir(keys[1], Dict{AbstractString, FileSystemObject}()))
        add_dir!(inner_dir, keys[2:end])
        fs.children[keys[1]] = inner_dir
    end
end

function add_file!(fs::Dir, keys::Vector{S}, f::File) where {S <: AbstractString}
    if length(keys) == 1
        if keys[1] == "/"
            add_file!(fs, f)
        else
            add_file!(fs.children[keys[1]], f)
        end
    else
        if fs.name == "/" && keys[1] == "/"
            return add_file!(fs, keys[2:end], f)
        end

        add_file!(fs.children[keys[1]], keys[2:end], f)
    end
end

function parsefs(cmds::Vector{Vector{AbstractString}})
    fs = Dir("/", Dict{AbstractString, FileSystemObject}())
    curr_path = "/"
    for c in cmds
        cmd, out... = c

        if startswith(cmd, "cd")
            @assert isempty(out)
            p = strip(cmd[3:end])

            if p == ".."
                curr_path = dirname(curr_path)
            elseif p == "/"
                curr_path = "/"
            else
                curr_path = joinpath(curr_path, p)
            end
        elseif startswith(cmd, "ls")
            @assert isempty(strip(cmd[3:end]))
            ps = splitpath(curr_path)

            for o in out
                t, n = split(o)

                if t == "dir"
                    add_dir!(fs, vcat(ps, n))
                else
                    sz = parse(Int, t)
                    add_file!(fs, ps, File(sz, n))
                end
            end
        else
            error("unreachable")
        end
    end

    return fs
end

function parse_input(data_file::String)
    cmds = Vector{AbstractString}[split(strip(strip(line, '$')), '\n') for line in split(read("data07.txt", String), "\n\$")]
    return parsefs(cmds)
end


### Part 1

Base.isdir(node::FileSystemObject) = isa(node, Dir)

dir_size(dir::Dir) = isempty(dir.children) ? 0 : sum(isdir(f) ? dir_size(f) : f.sz for f in values(dir.children))

function part1(node::Dir, max_sz::Int)
    res = 0
    if isa(node, Dir)
        sz = dir_size(node)

        if sz <= max_sz
            res += sz
        end

        for child in values(node.children)
            isdir(child) || continue
            res += part1(child, max_sz)
        end
    end

    return res
end

part1(fs::Dir) = part1(fs, 100_000)


### Part 2

function part2(node::Dir, space_avail::Int, space_needed::Int, curr_min_max::Int = 100_000_000)
    if isa(node, Dir)
        sz = dir_size(node)

        if sz >= (space_needed - space_avail) && (curr_min_max == -1 || sz <= curr_min_max)
            curr_min_max = sz
        end

        for child in values(node.children)
            isdir(child) || continue
            curr_min_max = part2(child, space_avail, space_needed, curr_min_max)
        end
    end

    return curr_min_max
end
part2(fs::Dir) = part2(fs, 70_000_000 - dir_size(fs), 30_000_000)


### Main

function main()
    data = parse_input("data07.txt")

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == 1086293
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    @assert part2_solution == 366028
    println("Part 2: $part2_solution")
end

main()
