#----- LinPredUnary ------------------------------------------------------------

#***TODO: BIG PROBLEM TO FIX:  if I just use M.unary in my code, it returns an 
# object of type LinPredUnary, NOT a vector of floats.  This causes massive slowdowns.

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

# Methods required for AbstractArray interface
Base.size(u::LinPredUnary) = size(u.X)[[1,3]]
function Base.values(u::LinPredUnary)
    out = Array{Float64,2}(undef,size(u))
    for r = 1:size(u)[2]
        out[:,r] = u.X[:,:,r]*u.β
    end
    return out
end
Base.getindex(u::LinPredUnary, i::Int, j::Int) = Base.values(u)[i,j]
Base.setindex!(u::LinPredUnary, v::Real, i::Int, j::Int) =
    error("Values of $(typeof(u)) must be set using setparameters!().")
#= TODO: finalize getindex for speed
Base.getindex(u::LinPredUnary, I::Vararg{Int,2}) = Base.values(u)[CartesianIndex(I)]
Base.setindex!(u::LinPredUnary, v::Real, I::Vararg{Int,2}) =
    error("Values of $(typeof(u)) must be set using setparameters!().")
=#

# Methods required for AbstractUnary interface
getparameters(u::LinPredUnary) = u.β
function setparameters!(u::LinPredUnary, newpars::Vector{Float64})
    u.β[:] = newpars
end


