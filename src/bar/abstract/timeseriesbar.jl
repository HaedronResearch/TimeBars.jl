"""
$(TYPEDEF)
A `SeriesBar` where the index is a time series.

Conditions that must be true for `StructArray{<:TimeSeriesBar}` validity (in addition to all inherited conditions from the parent bar):
* index element type is or contains a temporal value

Here we are deliberately abstract/agnostic about what is meant by "temporal value" for the sake of generality, subtypes will enforce what `TimeSeriesBar` actually looks like.
"""
abstract type TimeSeriesBar <: SeriesBar end

"""
$(TYPEDSIGNATURES)
Default single index name (or time-related index component) for time series.
"""
@inline default_index(::Type{<:TimeSeriesBar}) = :dt

"""
$(TYPEDSIGNATURES)
Split bar series, `v`, into partitions by `floor(idx, τ)`.
Partitions are inclusive on both ends.
"""
function parts(v::StructVector{T}, τ::Dates.Period, idx::AbstractVector; check=false) where {T<:TimeSeriesBar}
	check && @assert (issorted(idx) && issorted(v)) # (assume data / index are sorted)
	r = floor(first(idx), τ):τ:floor(last(idx), τ)
	[@view v[searchsortedfirst(idx, s):searchsortedlast(idx, s+τ)] for s=r]
end

"""
$(TYPEDSIGNATURES)
"""
function parts(v::StructVector{T}, τ::Dates.Period, f::Function; check=false) where {T<:TimeSeriesBar}
	parts(v, τ, f(v); check=check)
end

"""
$(TYPEDSIGNATURES)
Convenience fallback.
"""
function parts(v::StructVector{T}, τ::Dates.Period; check=false, idxkey=default_index(T)) where {T<:TimeSeriesBar}
	parts(v, τ, StructArrays.component(v, idxkey); check=check)
end

# function parts(v::StructVector{T}, τ::Dates.Period; idxkey::Symbol=default_index(T)) where {T<:TimeSeriesBar}
# 	@warn "This method is a slow fallback, it should be overloaded instead of called."
# 	λ = PartitionBy(bar->floor(getfield(bar, idxkey), τ))
# 	v |> λ |> collect
# end

# function parts(v::StructVector{T}, τ::Dates.Period, f::Function) where {T<:TimeSeriesBar}
# 	λ = PartitionBy(bar->floor(f(bar), τ))
# 	v |> λ |> collect
# end

# """
# Subset
# """
# function sub(arr::StructArray{<:TimeSeriesBar}, τ::Dates.Period)
# end

# function groupby(arr::AbstactVector{<:TimeSeriesBar}, τ::Dates.Period)
# end
