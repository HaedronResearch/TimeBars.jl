"""
$(TYPEDSIGNATURES)
Default Impute.jl chain.
"""
imputer(::Type{<:SeriesBar}; kw...) = Impute.Interpolate(;r=RoundNearest) ∘ Impute.NOCB() ∘ Impute.LOCF()
