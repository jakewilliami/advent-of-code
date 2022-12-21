f = "data21.txt"
f = "test.txt"

function parse_input(data_file)
    data = Dict{Symbol, Union{Int, Expr}}()
    for line in eachline(data_file)
        l, r = split(line, ": ")
        data[Symbol(l)] = Meta.parse(r)
    end

    return data
end

data = parse_input(f)

function evaluate!(ex::Expr, data)
    for (i, a) in enumerate(ex.args)
        haskey(data, a) || continue
        v = data[a]
        if v isa Int
            Base.Cartesian.lreplace!(ex, Base.Cartesian.LReplace(a, v))
        else
            ex.args[i] = evaluate!(v, data)
        end
    end

    return ex
end



function main(data)
    println("Orig expr: $(repr(data[:root]))")
    ex = copy(data[:root])
    evaluate!(ex, data)
    return round(Int, Meta.eval(ex))
end

println(main(data))


function get_target(ex::Expr, data)
    ex′ = data[ex.args[end]]  # Our target one of the sides of the target equation
    evaluate!(ex′, data)
    target = round(Int, Meta.eval(ex′))
    return target
end


function solve(ex::Expr, data)
    target = get_target(ex, data)
    println("Using target $target")
    ex, data = copy(ex), deepcopy(data)
    # target = main(data)

    # Binary search
    lo = 0
    hi = round(BigInt, 1e20)
    while lo < hi
        mid = (lo + hi) ÷ 2
        evaluate!(ex, data)
        score = target - Meta.eval(ex)
        if score < 0
            lo = mid
        elseif score == 0
            return mid
        else
            hi = mid
        end
    end

    return



    for (i, a) in enumerate(ex.args)

    end

    return ex
end


#=function substitute(e::Expr, pair)
    MacroTools.postwalk(e) do s
        a, b = pair
        s == a && return b
        s
    end
end=#

# using Symbolics
# using MacroTools

function substitute!(ex::Expr, data, v)

    for (i, a) in enumerate(ex.args)
        a == Symbol(v) && (ex.args[i] = v)
        haskey(data, a) || continue

        w = data[a]
        if w isa Int
            # ex = substitute(ex, Dict(a => data[a]))
        end
    end

    return ex
end


function main2(data)
    # v = data[:humn]
    ex = copy(data[:root])
    ex.args[1] = :(==)

    return solve(ex, data)





    data = deepcopy(data)
    delete!(data, :humn)
    data[:humn] = :x
    #=ex = copy(data[:root])
    ex.args[1] = :(==)
    v = data[:humn]
    while !Meta.parse(evaluate!(copy(ex), data))

    end
    return v=#

    # @variables humn

    ex = copy(data[:root])
    # ex.args[1] = :(==)
    delete!(data, :root)

end

println(main2(data))
