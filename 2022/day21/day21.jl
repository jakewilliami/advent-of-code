using NonlinearSolve, ModelingToolkit

using SimpleNonlinearSolve

f = "data21.txt"
f = "test.txt"

function parse_input(data_file)
    data = Dict{Symbol, Union{Integer, Expr}}()
    for line in eachline(data_file)
        l, r = split(line, ": ")
        data[Symbol(l)] = Meta.parse(r)
    end

    return data
end

data = parse_input(f)

function evaluate!(ex::Expr, data; ignore = Set{Symbol}())
    any(a ∈ ignore for a in ex.args) && return ex
    for (i, a) in enumerate(ex.args)
        haskey(data, a) || continue
        v = data[a]
        if v isa Integer
            Base.Cartesian.lreplace!(ex, Base.Cartesian.LReplace(a, v))
        else
            ex.args[i] = evaluate!(v, data)
        end
    end

    return ex
end



function main(data)
    println("Orig expr: $(repr(data[:root]))")
    data = deepcopy(data)
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


function solve′(ex::Expr, data)
    var = :humn
    target = get_target(ex, data)
    println("Using target $target")
    ex, data = copy(ex), deepcopy(data)
    # target = main(data)

    # Binary search
    lo = 0
    hi = typemax(Int)# round(BigInt, 1e20)
    while lo < hi
        mid = (lo + hi) ÷ 2
        data[var] = mid
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

# using NLsolve



expr_to_symbolic(x::Number, mod) = x
function expr_to_symbolic(x::Symbol, mod)
  if isdefined(mod, x)
    getfield(mod, x)
  else
    (@variables $x)[1]
  end
end
function expr_to_symbolic(ex, mod)
    if ex.head == :call
        if isdefined(mod, ex.args[1])
            return getfield(mod,ex.args[1])(expr_to_symbolic.(ex.args[2:end],(mod,))...)
        else
            x = expr_to_symbolic(ex.args[1], mod)
            ys = expr_to_symbolic.(ex.args[2:end],(mod,))
            return Term{Real}(x,[ys...])
        end
    end
end

macro expr_to_symbolic(ex)
    :(expr_to_symbolic($ex, @__MODULE__))
end


function mk_func(f::Symbol, args::Symbol...)
    return Expr(:call, f, args...)
end

function mk_assignment(lhs::Symbol, val::Expr)
    # return Expr(:call, :(~), lhs, val)
    return Expr(:(=), lhs, val)
end

function mk_assignment(lhs::Symbol, val::Int)
    # return Expr(:call, :(~), lhs, lhs)
    return Expr(:(=), lhs, val)
end

function _mk_scalar(f::Symbol, val::Expr, sig_args::NTuple{N1, Symbol}, def_args::NTuple{N2, Symbol}) where {N1, N2}
    @assert val.head == :call
    op = val.args[1]
    a, b = val.args[2:end]
    return :($f($(sig_args...)) = $op($a($(def_args...)), $b($(def_args...))))
    return quote
        # $(a)($(def_args...))
        # $(op)
        # $(b)($(def_args...))
        $(f)($(sig_args...)) = $(a)($(def_args...)) $(op) $(b)($(def_args...))
    end
end

function _mk_scalar(f::Symbol, val::Int, sig_args::NTuple{N1, Symbol}, _def_args::NTuple{N2, Symbol}) where {N1, N2}
    return :($f($(sig_args...)) = val)
    return quote
        $(f)($(sig_args...)) = $(val)
    end
end

function mk_scalar(ex::Expr, sig_args::NTuple{N1, Symbol}, def_args::NTuple{N2, Symbol}) where {N1, N2}
    # The input expression should be of the form: f = a + b (or some other infix operation)
    # We want to reduce these to scalar equations of the form f(x) = a(x) + b(x)
    # as each of these may be evaluated as functions.  E.g., a(x) might have an integer value
    # or might itself have another functional definition.
    @assert ex.head == :(=)
    f = ex.args[1]
    vars = ex.args[2]
    return _mk_scalar(f, vars, sig_args, def_args)
end

# julia> Meta.show_sexpr(Meta.parse("root = pppw - sjmn"))
# (:(=), :root, (:call, :-, :pppw, :sjmn))
#
# julia> Meta.show_sexpr(Meta.parse("root(x, p) = pppw(x) - sjmn(x)"))
# (:(=), (:call, :root, :x, :p), (:block,
#     :(#= none:1 =#),
#     (:call, :-, (:call, :pppw, :x), (:call, :sjmn, :x))
#   ))


function solve_la(ex::Expr, data, var::Symbol)
    # TODO: find var in data and modify
    ex, data = copy(ex), deepcopy(data)
    # modify data to be assignements
    # eltype: {Symbol, Union{Int, Expr}}
    # data = Dict(a => (e isa Int ? a : Expr(:(=), a, e)) for (a, e) in data)
    # data = Dict(a => (e isa Int ? Expr(:call, :(~), a, a) : Expr(:call, :(~), a, e)) for (a, e) in data)
    data = Dict(a => Expr(:call, :(~), a, e) for (a, e) in data)
    # data.
    delete!(data, var)
    println(data)


#=ex = [:(y ~ x)
      :(y ~ -2x + 3 / z)
      :(z ~ 2)]=#
    data[:root] = Expr(:call, :(~), data[:root].args[2], data[:root].args[3])

    eqs = expr_to_symbolic.(values(data), (Main,))
    vars = union(ModelingToolkit.vars.(eqs)...)
    push!(vars, var)
    println(eqs)
    println(vars)
    @named ns = NonlinearSystem(eqs, vars, [])

    prob = NonlinearProblem(ns,ones(length(data)))
    sol = solve(prob,NewtonRaphson())
    return sol

    ex = [:(y(t) ~ x(t))
          :(y(t) ~ -2x(t) + 3 / z(t))
          :(z(t) ~ 2)]
    eqs = expr_to_symbolic.(ex, (Main,))
    vars = union(ModelingToolkit.vars.(eqs)...)


    # TODO: something?
    #=k = findfirst(v -> v isa Expr && var ∈ v.args, data)
    j = findfirst(==(var), data[k].args)
    ex′ = data[data[k].args[j]]

    # A = zeros()

    if ex′ isa Expr
        evaluate!(ex′, data)
        n = ex′
    else
        n = ex′
    end

    return ex′


    return n
    evaluate!(ex′, data)
    return ex′=#




    # Initialise data
    # eltype: {Symbol, Tuple{Int, Union{Int, Expr}}}
    vars = Dict(a => (i, v) for (i, (a, v)) in enumerate(data))
    A = zeros(length(vars), length(vars))
    b = zeros(length(vars))

    # Delete target from data
    delete!(data, var)




    # evaluate!(ex, data, ignore = Set{Symbol}((var,)))
    # return ex



    # because humn is only ever used with + or -, this is a system of _linear_ equations
    #=for (a, (i, v)) in vars
        if v isa Int
            A[i, i] = 1.0
            b[i] = v
        elseif v isa Expr
            @assert v.head == :(=) "these data must be assignment"
            # @assert v.head == :call && first(v.args) == :(~) "these data must be assignment"
            lhs, rhs = v.args
            b[first(vars[lhs])] = 1.0
            ex′ = copy(v)
            println(ex′)
            evaluate!(ex′, data, ignore = Set{Symbol}(var))
            println(ex′)
            for w in ex′.args
                w ∈ keys(data) || continue
                println(w)
                if w == var
                    # TODO: this argument is the variable we are trying to solve
                else
                end
            end
        else
            error("unreachable: $(typeof(v))")
        end
    end=#










    #=convert_rhs_to_Expression(x::Number) = x

    @variables humn
    function convert_rhs_to_Expression(x::Symbol)
        return (@variables $x)[1]
    end

    function convert_rhs_to_Expression(ex::Expr)
        if ex.head == :call
            return getfield(Main, ex.args[1])(convert_rhs_to_Expression.(ex.args[2:end])...)
        end
        error("not yet implemented: $(ex.head)")
    end

    eqs = convert_rhs_to_Expression.(values(data))
    println(repr.(eqs))

    @named ns = NonlinearSystem(eqs, [humn], [])

    prob = NonlinearProblem(ns,[1.0])
    sol = solve(prob,NewtonRaphson())
    return sol=#








    #=for (a, (i, v)) in vars
        if v isa Int
            F[vars[a]] = v
        elseif v isa Expr
            h! = eval(v)
        else
            error("unreachable: $(typeof(v))")
        end
    end



    return=#

    # Fill in the matrix
    #=for (a, (i, v)) in vars
        if v isa Int
        elseif v isa Expr
            @assert v.head == :(=), "these data must be assignment"
            lhs, rhs = v.args

            # Fill in
        else
            error("unreachable: $(typeof(v))")
        end
    end=#
    #=function f!(F, vars)
        # TODO: fill this in with appropriate formulae depending on problem
        for (a, (i, v)) in vars
            if v isa Int
                F[vars[a]] = v
            elseif v isa Expr
                @assert v.head == :(=) "these data must be assignment"

                # Add expression to array, accounting for variables
                lhs, rhs = v.args
                # lhs == var && continue  # skip target variable
                F[vars[lhs]] = rhs#[rhs.args for j in 1:length(vars)]
            else
                error("unreachable: $(typeof(v))")
            end
        end
        println(F)
    end=#

    # Solve and extract solution
    # nlsolve(f!, b)
    # println(b)
    # return b


#=function f!(F, v)
           x = v[1]
           y = v[2]
           F[1] = -x + y
           F[2] = 2*x + y - 3
       end
nlsolve(f!, [0.0; 0.0])=#
    return (A \ b)[vars[var]]
end


function mk_scalar!(data)
    for (k, v) in data
        ass = mk_assignment(k, v)
        sig_args = k == :root ? (:x, :p) : (:x, )
        sig_args = (:x,)
        def_args = (:x,)
        f = mk_scalar(ass, sig_args, def_args)
        # println(f)
        data[k] = f
    end
    return data
end


function main2(data)
    data = deepcopy(data)
    mk_scalar!(data)
    for (_k, f) in data
        Meta.eval(f)
    end
    return root(1)
    return data


    return solve_la(data[:root], data, :humn)

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
