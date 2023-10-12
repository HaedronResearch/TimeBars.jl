"""
$(TYPEDEF)
A `TimeSeriesBar` whose temporal indexing type is a `Dates.TimeType`
(e.g. `Dates.DateTime`, `Dates.Date`, `Dates.Time`).

Conditions that must be true for `StructArray{<:TimeTypeBar}` validity (in addition to all inherited conditions from the parent bar):
* index must be a non-StructArray AbstractArray{<:Dates.TimeType} or a StructArray{<:NamedTuple} with a Dates.TimeType as a field type
"""
abstract type TimeTypeBar{Idx<:Dates.TimeType} <: TimeSeriesBar end

"""
$(TYPEDSIGNATURES)
Check if an object is a valid `StructArray{<:TimeTypeBar}`.

See `TimeTypeBar` for conditions that must be true for validity.
"""
function Base.isvalid(arr::StructArray{<:TimeTypeBar})
	parcond = invoke(Base.isvalid, Tuple{StructArray{<:supertype(TimeTypeBar)}}, arr)
	it = arr |> TimeBars.index |> typeof
	parcond && ((!(it <: StructArray) && it <: AbstractArray{<:TimeType}) || it <: StructArray{<:NamedTuple} && any(it |> eltype |> fieldtypes .<: TimeType))
end

"""
$(TYPEDSIGNATURES)
Check if `arr` is regular by at least periodicity `τ`
TODO
"""
function isregular(arr::StructArray{<:TimeTypeBar}, τ::Dates.Period)
	idx = TimeBars.index(arr)
end

"""
$(TYPEDSIGNATURES)
Forward fill `arr`
TODO
"""
function ffill(arr::StructArray{<:TimeSeriesBar})
end

"""
$(TYPEDSIGNATURES)
Backward fill `arr`
TODO
"""
function bfill(arr::StructArray{<:TimeSeriesBar})
end

"""
Subset
TODO
"""
function sub(arr::StructArray{<:TimeSeriesBar}, τ::Dates.Period)
end

"""
Split `arr` into partitions
https://en.wikipedia.org/wiki/Partition_of_a_set
TODO
"""
function parts(arr::AbstractVector{<:TimeSeriesBar}, τ::Dates.Period)
end

# function groupby(arr::AbstactVector{<:TimeSeriesBar}, τ::Dates.Period)
# end

# """
# A `TimeTypeBar` with an associated `Dates.Period`, which denotes its periodicity.
# """
# abstract type PeriodicTimeTypeBar{Idx,Per<:Dates.Period} <: TimeTypeBar{Idx} end

