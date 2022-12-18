using AdventOfCode
using Test

@testset "AdventOfCode.jl" begin
    @testset "AdventOfCode.jl/Multidimensional" begin
        using AdventOfCode.Multidimensional

        # Read
        p, fp = mktemp(cleanup = false)
        A = permutedims(reshape(0:9, (5, 2)))
        write(fp, "01234\n")
        write(fp, "56789\n")
        close(fp)
        @test readlines_into_char_matrix(p) == only.(string.((A)))
        @test readlines_into_int_matrix(p) == A
        rm(p)

        # Adjacencies
        @test n_cardinal_adjacencies(2) == 4
        @test n_cardinal_adjacencies(3) == 6
        @test n_faces(2) == 4
        @test n_faces(3) == 6
        @test n_adjacencies(2) == 8
        @test n_adjacencies(3) == 26
        i, j, k = CartesianIndex(3, 3), CartesianIndex(2, 2), CartesianIndex(2, 1)
        @test areadjacent(i, j)
        @test !areadjacent(i, k)

        # Origin
        @test 𝟘(2) == CartesianIndex(0, 0)
        @test 𝟘(3) == CartesianIndex(0, 0, 0)
        @test 𝟘(4) == CartesianIndex{4}() - CartesianIndex{4}()

        # Indexing
        M1 = Array{Int}(undef, 3, 3)
        M2 = Array{Int}(undef, 3, 4, 5)
        @test hasindex(M1, CartesianIndex(2, 2))
        @test !hasindex(M1, CartesianIndex(4, 4))
        @test hasindex(M2, CartesianIndex(2, 3, 4))
        @test hasindex(M2, CartesianIndex(3, 4, 5))
        @test !hasindex(M2, CartesianIndex(4, 5, 6))
        M3 = zeros(Int, 3, 3)
        M3[1, 2] = 69
        @test tryindex(M3, CartesianIndex(1, 2)) == 69
        @test isnothing(tryindex(M3, CartesianIndex(4, 4)))

        # Cartesian directions
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
    end
end
