"""
$(TYPEDEF)
A series indexed by time is a time series.
"""
abstract type TimeSeriesBar <: SeriesBar end

"""
$(TYPEDEF)
A time series whose indexing type is a `Dates.TimeType`
(e.g. `Dates.DateTime`, `Dates.Date`, `Dates.Time`)
"""
abstract type TimeTypeBar{Idx<:Dates.TimeType} <: TimeSeriesBar end

"""
$(TYPEDSIGNATURES)
Check if `arr` is regular by at least periodicity `τ`
"""
function isregular(arr::StructArray{<:TimeTypeBar}, τ::Dates.Period)
	idx = index(arr)
end

"""
$(TYPEDSIGNATURES)
Forward fill `arr`

"""
function ffill(arr::AbstractVector{<:TimeSeriesBar})
end

"""
$(TYPEDSIGNATURES)
Backward fill `arr`
"""
function bfill(arr::AbstractVector{<:TimeSeriesBar})
end

"""
Subset
"""
function sub(arr::AbstractVector{<:TimeSeriesBar}, τ::Dates.Period)
end

"""
Split `arr` into partitions
https://en.wikipedia.org/wiki/Partition_of_a_set
"""
# function parts(arr::AbstactVector{<:TimeSeriesBar}, τ::Dates.Period)
# end

# function groupby(arr::AbstactVector{<:TimeSeriesBar}, τ::Dates.Period)
# end

# """
# A `TimeTypeBar` with an associated `Dates.Period`, which denotes its periodicity.
# """
# abstract type PeriodicTimeTypeBar{Idx,Per<:Dates.Period} <: TimeTypeBar{Idx} end

