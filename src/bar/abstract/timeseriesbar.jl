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
Split timeseries, `v`, into partitions by periodicity `τ`.
Partitions are inclusive on both ends.

If `align` is set, the partitions are aligned to the calendar.
If `partial` is set, partial partitions (both ends) are included.
"""
function parts(v::StructVector{T}, τ::Dates.Period, dti::AbstractVector; align=true, partial=true, check=false) where {T<:TimeSeriesBar}
	f, l = first(dti), last(dti)
	if align
		if partial
			f, l = floor(f, τ), ceil(l, τ)
		else
			f, l = ceil(f, τ), floor(l, τ)
		end
	else
		if partial
			l += τ
		end
	end
	parts(v, f:τ:l, dti; check=check)
end

"""
$(TYPEDSIGNATURES)
Convenience fallback.
"""
function parts(v::StructVector{T}, τ::Dates.Period; align=true, partial=true, check=false, idxkey=default_index(T)) where {T<:TimeSeriesBar}
	parts(v, τ, StructArrays.component(v, idxkey); align=align, partial=partial, check=check)
end

# """
# Subset
# """
# function sub(arr::StructArray{<:TimeSeriesBar}, τ::Dates.Period)
# end

# function groupby(arr::AbstactVector{<:TimeSeriesBar}, τ::Dates.Period)
# end
