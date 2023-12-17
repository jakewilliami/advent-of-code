using AdventOfCode
using Test

@testset "AdventOfCode.jl" begin
    @testset "AdventOfCode.jl/Multidimensional" begin
        using AdventOfCode.Multidimensional
        import AdventOfCode.Multidimensional: _is_cardinal, _direction_in_dims

        M3 = zeros(Int, 3, 3)
        M3[1, 2] = 69

        @testset "AdventOfCode.jl/Multidimensional/Origin" begin
            @test 𝟘(2) == CartesianIndex(0, 0)
            @test 𝟘(3) == CartesianIndex(0, 0, 0)
            @test 𝟘(4) == CartesianIndex{4}() - CartesianIndex{4}()
        end

        @testset "AdventOfCode.jl/Multidimensional/Indexing" begin
            M1 = Array{Int}(undef, 3, 3)
            M2 = Array{Int}(undef, 3, 4, 5)
            @test hasindex(M1, CartesianIndex(2, 2))
            @test !hasindex(M1, CartesianIndex(4, 4))
            @test hasindex(M2, CartesianIndex(2, 3, 4))
            @test hasindex(M2, CartesianIndex(3, 4, 5))
            @test !hasindex(M2, CartesianIndex(4, 5, 6))
            @test tryindex(M3, CartesianIndex(1, 2)) == 69
            @test isnothing(tryindex(M3, CartesianIndex(4, 4)))

            # TODO: get `collect` and array comprehension working with `CartesianIndicesRowWise`
            I1 = []
            for i in CartesianIndicesRowWise(M1) push!(I1, i) end
            I2 = collect(Base.Iterators.flatten((CartesianIndex(row_i, col_i) for col_i in 1:length(row)) for (row_i, row) in enumerate(eachrow(M1))))
            @test I1 == I2
        end

        @testset "AdventOfCode.jl/Multidimensional/Directions" begin
            @test INDEX_RIGHT == CartesianIndex(0, 1)
            @test INDEX_LEFT == CartesianIndex(0, -1)
            @test INDEX_UP == CartesianIndex(-1, 0)
            @test INDEX_DOWN == CartesianIndex(1, 0)
            ℝ²_cardinal_directions = CartesianIndex.(((-1, 0), (1, 0), (0, -1), (0, 1)))
            ℝ²_directions_no_origin = (
                ℝ²_cardinal_directions...,
                CartesianIndex.(((-1, -1), (-1, 1), (1, -1), (1, 1)))...,
            )
            ℝ²_cartesian_directions = (ℝ²_directions_no_origin..., CartesianIndex(0, 0))
            @test all(∈(ℝ²_cardinal_directions), cardinal_directions(2))
            @test all(∈(ℝ²_directions_no_origin), cartesian_directions(2))
            @test all(
                ∈(ℝ²_cartesian_directions),
                cartesian_directions(2; include_origin = true),
            )
            @test direction(CartesianIndex(0, 0)) == CartesianIndex(0, 0)
            @test direction(CartesianIndex(1, 10)) == CartesianIndex(1, 1)
            @test direction(CartesianIndex(-69, 0)) == CartesianIndex(-1, 0)
            @test all(sum(map(abs, Tuple(d))) == 1 for d in cardinal_directions(3))
            @test all(_is_cardinal(d) for d in cardinal_directions(3))
            @test all(_direction_in_dims(d; dims=:) for d in cartesian_directions(2) if !_is_cardinal(d))
            for (d1, d2) in ((INDEX_RIGHT, INDEX_LEFT), (INDEX_UP, INDEX_DOWN), (INDEX_NORTH_EAST, INDEX_SOUTH_WEST), (INDEX_NORTH_WEST, INDEX_SOUTH_EAST))
                @test opposite_direction(d1) == d2
                @test opposite_direction(d2) == d1
                @test rot180(d1) == d2
            end
            @test is_horizontal(INDEX_RIGHT)
            @test !is_vertical(INDEX_RIGHT)
            @test _direction_in_dims(INDEX_RIGHT, dims=2)
            @test is_horizontal(INDEX_RIGHT) == isone(last(Tuple(INDEX_RIGHT)))
            @test is_vertical(INDEX_RIGHT) == isone(first(Tuple(INDEX_RIGHT)))
            @test !is_horizontal(INDEX_DOWN)
            @test is_vertical(INDEX_DOWN)
            @test _direction_in_dims(INDEX_DOWN, dims=1)
            @test is_horizontal(INDEX_DOWN) == isone(last(Tuple(INDEX_DOWN)))
            @test is_vertical(INDEX_DOWN) == isone(first(Tuple(INDEX_DOWN)))
            @test is_diagonal(INDEX_NORTH_EAST)
            @test _direction_in_dims(INDEX_NORTH_EAST, dims=(1, 2))
            @test rotl90(INDEX_ABOVE) == INDEX_LEFT
            @test rotr90(INDEX_ABOVE) == INDEX_RIGHT
            @test rotl90(INDEX_BELOW) == INDEX_RIGHT
            @test rotr90(INDEX_BELOW) == INDEX_LEFT
        end

        @testset "AdventOfCode.jl/Multidimensional/Adjacencies" begin
            @test n_cardinal_adjacencies(2) == 4
            @test n_cardinal_adjacencies(3) == 6
            @test n_faces(2) == 4
            @test n_faces(3) == 6
            @test n_adjacencies(2) == 8
            @test n_adjacencies(3) == 26
            i, j, k = CartesianIndex(3, 3), CartesianIndex(2, 2), CartesianIndex(2, 1)
            @test areadjacent(i, j)
            @test !areadjacent(i, k)
            @test M3[CartesianIndex{2}() + INDEX_RIGHT] == 69
            @test M3[CartesianIndex{2}() + 2INDEX_RIGHT + INDEX_LEFT] == 69
            indices1, indices2 = adjacent_cartesian_indices(M3, CartesianIndex{2}()), cartesian_adjacencies_with_indices(M3, CartesianIndex{2}())
            @test length(indices1) == length(indices2)
            for (a, (b, c)) in zip(indices1, indices2)
                @test a == b
                @test M3[a] == M3[b] == c
            end
        end
    end


    @testset "AdventOfCode.jl/Parsing" begin
        using AdventOfCode.Parsing

        # Integers
        s = "123...something 10 something 1 something else -1 1000 22 something else else -20"
        @test get_integers(s) == Int[123, 10, 1, 1, 1000, 22, 20]
        @test get_integers(s; negatives = true) == Int[123, 10, 1, -1, 1000, 22, -20]

        # Matrices
        p, fp = mktemp(cleanup = false)
        A = permutedims(reshape(0:9, (5, 2)))
        write(fp, "01234\n")
        write(fp, "56789\n")
        close(fp)
        @test readlines_into_char_matrix(p) == only.(string.((A)))
        @test readlines_into_int_matrix(p) == A
        rm(p)
    end
end
