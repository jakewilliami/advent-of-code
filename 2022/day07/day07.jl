data = [strip(strip(line, '$')) for line in split(read("data07.txt", String), "\n\$")]
# data = [strip(strip(line, '$')) for line in split(read("test.txt", String), "\n\$")]

cmds = []
for cmd_str in data
    push!(cmds, split(cmd_str, '\n'))
end

abstract type FileSystemObject end

struct File <: FileSystemObject
    sz::Int
    name::AbstractString
end

struct Dir <: FileSystemObject
    name::AbstractString
    children::Dict{AbstractString, FileSystemObject}
end

function add_node!(dir::Dir, f::FileSystemObject)
    # Add the file to the children of the directory
    return dir.children[f.name] = f
end
function add_file!(dir::Dir, f::File)
    # Add the file to the children of the directory
    # return setindex!(dir.children, f.name, f)
    return dir.children[f.name] = f
end
function add_dir!(dir::Dir, new_dir_name::S) where {S <: AbstractString}
    # println("ADD DIR STR: ", dir)
    # inner_dir = get(dir.children, new_dir_name, Dir(new_dir_name, Dict{AbstractString, FileSystemObject}()))
    dir.children[new_dir_name] = Dir(new_dir_name, Dict{AbstractString, FileSystemObject}())
    # println("ADD DIR STR NEW: ", dir)
    return
    # Add the file to the children of the directory
    # return setindex!(dir.children, new_dir.name, new_dir)
    new_dir = Dir(new_dir_name, Dict{AbstractString, FileSystemObject}())
    return dir.children[new_dir_name] = new_dir
    return setindex!(dir.children, new_dir_name, new_dir)
end

function add_dir!(fs::Dir, keys::Vector{S}) where {S <: AbstractString}
    # println("ADD DIR KEYS: ", fs)
    if length(keys) == 1
        add_dir!(fs, keys[1])
    else
        if fs.name == "/" && keys[1] == "/"
            # println("ROOT BYPASS: ", keys[2:end])
            return add_dir!(fs, keys[2:end])
        end
        # if fs.name == "/"
            # return add_dir!(fs, keys[2:end])
        # end
        # println("CHILDREN: ", fs)
        inner_dir = get(fs.children, keys[1], Dir(keys[1], Dict{AbstractString, FileSystemObject}()))
        add_dir!(inner_dir, keys[2:end])
        fs.children[keys[1]] = inner_dir
    end
end
function add_file!(fs::Dir, keys::Vector{S}, f::File) where {S <: AbstractString}
    # println(fs)
    # println(keys)
    # println(f)
    # println("ADD FILE KEYS: ", fs)
    if length(keys) == 1
        # println("Adding $(keys[1]) to fs ($(fs.children))")
        if keys[1] == "/"
        add_file!(fs, f)
        else
        add_file!(fs.children[keys[1]], f)
        end
    else
        if fs.name == "/" && keys[1] == "/"
            # println("ROOT BYPASS: ", keys[2:end])
            return add_file!(fs, keys[2:end], f)
        end
        # println(fs)
        # if haskey(fs.children, keys[1])
            # add_dir!(fs.children[keys[1]], keys[2:end])
        # else
            # fs.children[keys[1]] = Dir(keys[1], Dict{AbstractString, FileSystemObject}())
        # end

        # add_file!(fs.children[keys[1]], )
        # inner_dir = get(fs.children, keys[1], Dir(keys[1], Dict{AbstractString, FileSystemObject}()))
        add_file!(fs.children[keys[1]], keys[2:end], f)
        # fs.children[keys[1]] = inner_dir
    end
end

function update_file_system!(directory::Dir, path::Vector{String})
    # If the path is empty, return the current directory
    if length(path) == 0
        return directory
    else
        # Get the next directory in the path
        next_dir_name = path[1]

        # Check if the next directory exists in the children of the current directory
        if haskey(directory.children, next_dir_name)
            # If the next directory exists, traverse the file system recursively starting from that directory
            next_dir = directory.children[next_dir_name]
            return update_file_system!(next_dir, path[2:end])
        else
            # If the next directory does not exist, create a new directory and add it to the children of the current directory
            next_dir = Dir(next_dir_name, Dict{AbstractString, FileSystemObject}())
            add_node!(directory, next_dir)
            return update_file_system!(next_dir, path[2:end])
        end
    end
end

function parsefs(data)
# fs = Dict()
fs = Dir("/", Dict{AbstractString, FileSystemObject}())
curr_path = "/"
for c in cmds
    # println("CMD: ", repr(c))
    # println("STATE: ", repr(fs))
    cmd, out... = c
    if startswith(cmd, "cd")
        @assert isempty(out)
        # println(cmd)
        p = strip(cmd[3:end])
        if p == ".."
            # println("DIRNAME ($(repr(curr_path))) -> $(repr(dirname(curr_path)))")
            curr_path = dirname(curr_path)
        elseif p == "/"
            curr_path = "/"
        else
            # println("CD $(repr(p)) -> $(repr(joinpath(curr_path, p)))")
            curr_path = joinpath(curr_path, p)
        end
    elseif startswith(cmd, "ls")
        @assert isempty(strip(cmd[3:end]))
        # println("CURR PATH: ", curr_path)
        ps = splitpath(curr_path)
        # update_dict!(fs, ps, Dict())
        # update_fs!(fs, vcat(ps))
        # ps = splitpath(curr_path)
        for o in out
            t, n = split(o)
            if t == "dir"
                # println(1, " ", cmd, ps, out)
                # println("ONE: ", fs)
                # println("ADD DIR: ", vcat(ps, n))
                add_dir!(fs, vcat(ps, n))
                # println("TWO: ", fs)
                # update_file_system!(fs, ps)
                # Dir(n)
                # update_dict!(fs, ps, Dict(n => Dict()))
            else
                # println(ps)
                # println(2, " ", cmd, ps, out)
                sz = parse(Int, t)
                # println("ADD FILE: ", ps, " -> ", File(sz, n))
                add_file!(fs, ps, File(sz, n))
                # update_dict!(fs, ps, File(sz, n))
            end
        end
        #=
        for o in out
            t, n = split(o)
            if t == "dir"
                # Dir(n)
                update_dict!(fs, ps, Dict(n => Dict()))
            else
                println(ps)
                sz = parse(Int, t)
                update_dict!(fs, ps, File(sz, n))
            end
        end =#
        #=println(ps)
        curr = fs
        for p in ps[1:end]  # 2
            if haskey(curr, p)
                curr = curr[p]
            else
                curr = Dict()
            end
        end
        fs = merge(fs, curr)=#
    else
        error("unreachable")
    end
end

return fs
# println(cmds)
# println(fs)
end

fs = parsefs(data)
# println(fs)

Base.isdir(node::FileSystemObject) = isa(node, Dir)

dir_size(dir::Dir) = isempty(dir.children) ? 0 : sum(isdir(f) ? dir_size(f) : f.sz for f in values(dir.children))

#=function dir_size(dir::Dir)
    if isempty(dir.children)
        return 0
    else
        res = 0
        for f in values(dir.children)
            println(f)
            sz = isdir(f) ? dir_size(f) : f.sz
            res += sz
        end
        return res
    end
end=#

function part1(node::Dir, max_sz::Int)
    res = 0
    # println("RES: $res")
    if isa(node, Dir)
        # println(node)
        sz = dir_size(node)
        # println(sz, " <- ", sz <= max_sz)
        if sz <= max_sz
            # println("RES WHEN FOUND: $res")
            res += sz
            # println("RES AFTER FOUND: $res")
        end
        for child in values(node.children)
            # println("ANOTHER RES: ", res)
            isdir(child) || continue
            # println(child)
            res += part1(child, max_sz)
        end
    end
    return res
end

# println("==================================================")
println(part1(fs, 100_000))
println(dir_size(fs))

curr_min_max = -1
function part2(node::Dir, space_avail, space_needed)
    global curr_min_max
    if isa(node, Dir)
        sz = dir_size(node)
        # println(sz)
        # println("We need $space_needed - $space_avail = $(space_needed - space_avail) bytes to clear up enough space on the hard drive.  Our current best bet for clearing up space is to remove $curr_min_max bytes.  The current size is $sz, which is $sz < $(space_needed - space_avail) = $(sz < (space_needed - space_avail))")
        if sz >= (space_needed - space_avail) && (curr_min_max == -1 || sz <= curr_min_max)
            curr_min_max = sz
        end
        for child in values(node.children)
            isdir(child) || continue
            part2(child, space_avail, space_needed)
        end
    end
    # return curr_min_max
end

println(part2(fs, 70_000_000 - dir_size(fs), 30_000_000))
println(curr_min_max)
