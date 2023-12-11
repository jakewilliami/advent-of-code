_mk_cartesian_index(v::I1, n::I2) where {I1 <: Integer, I2 <: Integer} = CartesianIndex(ntuple(_ -> v, n))
