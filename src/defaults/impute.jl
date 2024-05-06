"""
$(TYPEDSIGNATURES)
Default Impute.jl chain.
"""
@inline default_imputer(::Type{<:SeriesBar}) = Impute.Interpolate(;r=RoundNearest) ∘ Impute.NOCB() ∘ Impute.LOCF()
