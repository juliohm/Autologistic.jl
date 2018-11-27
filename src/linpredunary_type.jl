#----- LinPredUnary ------------------------------------------------------------

# The unary part containing a regression linear predictor.
# X is an n-by-p-by-m matrix (n obs, p predictors, m replicates)
# β is a p-vector of parameters (same for all replicates)
struct LinPredUnary <: AbstractUnary
    X::Array{Float64, 3}
    β::Vector{Float64}

    function LinPredUnary(x, beta) 
        if size(x)[2] != length(beta)
            error("LinPredUnary: X and β dimensions are inconsistent")
        end
        new(x, beta)
    end
end

# Constructors
function LinPredUnary(X::Matrix{Float64}, β::Vector{Float64})
    (n,p) = size(X)
    return LinPredUnary(reshape(X,(n,p,1)), β)
end
function LinPredUnary(X::Matrix{Float64})
    (n,p) = size(X)
    return LinPredUnary(reshape(X,(n,p,1)), Vector{Float64}(undef,p))
end
function LinPredUnary(X::Array{Float64, 3})
    (n,p,m) = size(X)
    return LinPredUnary(X, Vector{Float64}(undef,p))
end
function LinPredUnary(n::Int,p::Int)
    X = Array{Float64,3}(undef,n,p,1)
    return LinPredUnary(X, Vector{Float64}(undef,p))
end
function LinPredUnary(n::Int,p::Int,m::Int)
    X = Array{Float64,3}(undef,n,p,m)
    return LinPredUnary(X, Vector{Float64}(undef,p))
end

#---- AbstractArray methods ----

Base.size(u::LinPredUnary) = (size(u.X,1), size(u.X,3))

# getindex - implementations

function Base.getindex(u::LinPredUnary, ::Colon, ::Colon)
    n, p, m = size(u.X)
    out = zeros(n,m)
    for r = 1:m
        for i = 1:n
            for j = 1:p
                out[i,r] += u.X[i,j,r] * u.β[j]
            end
        end
    end
    return out
end

function Base.getindex(u::LinPredUnary, I::AbstractArray)
    out = u[:,:]
    return out[I]
end

Base.getindex(u::LinPredUnary, i::Int, r::Int) = sum(u.X[i,:,r] .* u.β)   

function Base.getindex(u::LinPredUnary, ::Colon, r::Int) 
    n, p, m = size(u.X)
    out = zeros(n)
    for i = 1:n
        for j = 1:p
            out[i] += u.X[i,j,r] * u.β[j]
        end
    end
    return out
end

function Base.getindex(u::LinPredUnary, I::AbstractVector, R::AbstractVector)
    out = zeros(length(I),length(R))
    for r in 1:length(R)
        for i in 1:length(I)
            for j = 1:size(u.X,2)
                out[i,r] += u.X[I[i],j,R[r]] * u.β[j]
            end
        end
    end
    return out
end

# getindex- translations
Base.getindex(u::LinPredUnary, I::Tuple{Integer, Integer}) = u[I[1], I[2]]
Base.getindex(u::LinPredUnary, ::Colon, j::Int) = u[1:size(u.X,1), j]
Base.getindex(u::LinPredUnary, i::Int, ::Colon) = u[i, 1:size(u.X,3)]
Base.getindex(u::LinPredUnary, I::AbstractRange{<:Integer}, J::AbstractVector{Bool}) = u[I,findall(J)]
Base.getindex(u::LinPredUnary, I::AbstractVector{Bool}, J::AbstractRange{<:Integer}) = u[findall(I),J]
Base.getindex(u::LinPredUnary, I::Integer, J::AbstractVector{Bool}) = u[I,findall(J)]
Base.getindex(u::LinPredUnary, I::AbstractVector{Bool}, J::Integer) = u[findall(I),J]
Base.getindex(u::LinPredUnary, I::AbstractVector{Bool}, J::AbstractVector{Bool}) = u[findall(I),findall(J)]
Base.getindex(u::LinPredUnary, I::AbstractVector{<:Integer}, J::AbstractVector{Bool}) = u[I,findall(J)]
Base.getindex(u::LinPredUnary, I::AbstractVector{Bool}, J::AbstractVector{<:Integer}) = u[findall(I),J]

# setindex!
Base.setindex!(u::LinPredUnary, v::Real, i::Int, j::Int) =
    error("Values of $(typeof(u)) must be set using setparameters!().")

#---- AbstractUnary interface ----
getparameters(u::LinPredUnary) = u.β
function setparameters!(u::LinPredUnary, newpars::Vector{Float64})
    u.β[:] = newpars
end


