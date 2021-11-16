"""
TullioStatistics implements many basic statistics functions, but faster.
"""
module TullioStatistics

using Tullio
using LoopVectorization



###### BASIC FUNCTIONS

sum(A::AbstractVector{T}) where {T} = @tullio (+) R := A[i]
sum(f::Function,A::AbstractVector{T},c=0.0) where {T} = @tullio (+) R := f(A[i]-c)


prod(A::AbstractVector{T}) where {T} = @tullio (*) R := A[i]
prod(f::Function,A::AbstractVector{T},c=0.0) where {T} = @tullio (*) R := f(A[i]-c)

maximum(A::AbstractVector{T}) where {T} = @tullio (max) R := A[i]
maximum(f::Function,A::AbstractVector{T},c=0.0) where {T} = @tullio (max) R := f(A[i]-c)

minimum(A::AbstractVector{T}) where {T} = @tullio (min) R := A[i]
minimum(f::Function,A::AbstractVector{T},c=0.0) where {T} = @tullio (min) R := f(A[i]-c)


function sum(A::AbstractMatrix{T};dims=:) where {T}
    (isequal(dims,:) || isequal(dims,(1,2))) && (return @tullio (+) R := A[i,j])
    isequal(dims,1) && (return @tullio (+) R[1,j] := A[i,j])
    isequal(dims,2) && (return @tullio (+) R[i] := A[i,j])
    dims > 2 && return A
end

function sum(f::Function,A::AbstractMatrix{T},c::Number=0.0;dims=:) where {T}
    (isequal(dims,:) || isequal(dims,(1,2))) && (return @tullio (+) R := f(A[i,j]-c))
    isequal(dims,1) && (return @tullio (+) R[1,j] := f(A[i,j]-c))
    isequal(dims,2) && (return @tullio (+) R[i] := f(A[i,j]-c))
    dims > 2 && return f.(A.-c)
end
function sum(f::Function,A::AbstractMatrix{T},c::AbstractVecOrMat{S};dims=1) where {T,S}
    N,K = size(c)
    @assert (isequal(dims,:) || isequal(dims,(1,2))) "`dims` "
    isequal(dims,1) && (return @tullio (+) R[1,j] := f(A[i,j]-c[i]))
    isequal(dims,2) && (return @tullio (+) R[i] := f(A[i,j]-c[j]))
    dims > 2 && return f.(A.-c)
end
prod(A::AbstractMatrix{T}) where {T} = @tullio (*) R := A[i]
maximum(A::AbstractMatrix{T}) where {T} = @tullio (max) R := A[i]
minimum(A::AbstractMatrix{T}) where {T} = @tullio (min) R := A[i]






###### UNIVARIATE STATS

# MEAN
function mean(A::AbstractVector{T}) where {T}
    N = length(A)
    return sum(A)/N
end

function mean(f::Function,A::AbstractVector{T},c=0.0) where {T}
    N = length(A)
    return sum(f,A,c)/N
end


function mean(A::AbstractMatrix{T};dims=:) where {T}
    N,K = size(A)
    Y = N*K
    isequal(dims,:) && return sum(A)/Y
    isequal(dims,1) && return sum(A,dims=1)/N
    isequal(dims,2) && return sum(A,dims=2)/K
    dims > 2 && return A
end

function mean(f::Function,A::AbstractMatrix{T},c=0.0;dims=:) where {T}
    N,K = size(A)
    Y = N*K
    isequal(dims,:) && return sum(f,A,c)/Y
    isequal(dims,1) && return sum(f,A,c;dims=1)/N
    isequal(dims,2) && return sum(f,A,c;dims=2)/K
    dims > 2 && return f.(A.-c)
end




# VARM
function varm(A::AbstractVector{T}, m; corrected::Bool=true) where {T}
    N = length(A)
    res = mean(abs2,A,m)
    corrected && return res*N/(N-1)
    return res
end

function varm(f::Function,A::AbstractVector{T}, m; corrected::Bool=true) where {T}
    N = length(A)
    res = mean(abs2 ∘ f,A) - m^2
    corrected && return res*N/(N-1)
    return res
end


function varm(A::AbstractMatrix{T}, m; dims=:, corrected::Bool=true) where {T}
    N,K = size(A)
    
    if isequal(dims,:)
        @assert length(m) == 1 "Dimension mismatch between `m` and `dims`."
        return varm(vec(A),m; corrected=corrected)
    elseif isequal(dims,1) & length(m)==1
        top = sum(abs2,A,m; dims=1)
        res = corrected ? top./(N-1) : top./N
        return res
    elseif isequal(dims,2)
        return sum(A,dims=2)/K
    else
        dims > 2 && return A
    end
end













### MOVING WINDOW STATS 

# SUM 
# tulinnersum!(B,A,n) = @tullio B[i] = A[i+j] (j in 0:n)

# function tulouter(A::AbstractVector{T},w; padded::Bool=true,padvalue=missing) where {T}
#     L = length(A)
#     Lw = length(w)
#     if !padded
#         R = tulinnersum!(zeros(L-Lw+1),A,Lw-1)
#     else
#         minw = minimum(w)
#         maxw = maximum(w)
#         R = Vector{Union{T,typeof(P)}}(undef,L)

#     end
#     return R
# end

# DIFFERENCE

# AVERAGE

# MAX / MIN

# PRODUCT

# STD







##### MULTIVARIATE STATS

end # module
