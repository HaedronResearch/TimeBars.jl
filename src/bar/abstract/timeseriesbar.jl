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
Split bar series into partitions by `floor(idxkey(bar), τ)`.
"""
function parts(v::StructVector{T}, τ::Dates.Period; partkey::Symbol=default_index(T)) where {T<:TimeSeriesBar}
	λ = PartitionBy(bar->floor(getproperty(bar, partkey), τ))
	v |> λ |> collect
end

# """
# Subset
# """
# function sub(arr::StructArray{<:TimeSeriesBar}, τ::Dates.Period)
# end

# function groupby(arr::AbstactVector{<:TimeSeriesBar}, τ::Dates.Period)
# end
