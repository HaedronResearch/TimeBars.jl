"""
$(TYPEDEF)
A `SeriesBar` where the index is a time series.

Conditions that must be true for `StructArray{<:TimeSeriesBar}` validity (in addition to all inherited conditions from the parent bar):
* index contains (or is) a temporal value

Here we are deliberately abstract/agnostic about what is meant by "temporal value" for the sake of generality, subtypes will enforce what `TimeSeriesBar` actually looks like.
"""
abstract type TimeSeriesBar <: SeriesBar end

# """
# $(TYPEDSIGNATURES)
# Forward fill `arr`
# """
# function ffill(arr::StructArray{<:TimeSeriesBar})
# end

# """
# $(TYPEDSIGNATURES)
# Backward fill `arr`
# """
# function bfill(arr::StructArray{<:TimeSeriesBar})
# end

# """
# Subset
# """
# function sub(arr::StructArray{<:TimeSeriesBar}, τ::Dates.Period)
# end

# """
# Split `arr` into partitions
# https://en.wikipedia.org/wiki/Partition_of_a_set
# """
# function parts(arr::AbstactVector{<:TimeSeriesBar}, τ::Dates.Period)
# end

# function groupby(arr::AbstactVector{<:TimeSeriesBar}, τ::Dates.Period)
# end
