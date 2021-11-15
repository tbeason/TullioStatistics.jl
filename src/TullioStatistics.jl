"""
TullioStatistics implements most of Statistics, but faster.
"""
module TullioStatistics

using Tullio
using LoopVectorization







###### UNIVARIATE STATS
















### MOVING WINDOW STATS 

# SUM 
tulinnersum!(B,A,n) = @tullio B[i] = A[i+j] (j in 0:n)

function tulouter(A::AbstractVector{T},w; padded::Bool=true,padvalue=missing) where {T}
    L = length(A)
    Lw = length(w)
    if !padded
        R = tulinnersum!(zeros(L-Lw+1),A,Lw-1)
    else
        minw = minimum(w)
        maxw = maximum(w)
        R = Vector{Union{T,typeof(P)}}(undef,L)

    end
    return R
end

# DIFFERENCE

# AVERAGE

# MAX / MIN

# PRODUCT

# STD







##### MULTIVARIATE STATS

end # module
