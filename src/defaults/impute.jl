"""
$(TYPEDSIGNATURES)
Default Impute.jl chain.
"""
default_imputer(::Type{<:SeriesBar}) = Impute.Interpolate(;r=RoundNearest) ∘ Impute.NOCB() ∘ Impute.LOCF()
