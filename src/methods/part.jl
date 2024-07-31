"""
$(TYPEDSIGNATURES)
Partition based on (inclusive) integer index cut points.
"""
function part(v::StructVector{T}, cuts::AbstractVector{<:Integer}; check=default_check(T)) where {T<:SeriesBar}
	check && @assert (issorted(v) && issorted(cuts) && allunique(cuts))
	slices = (cuts[i]:cuts[i+1] for i=firstindex(cuts):length(cuts)-1)
	[view(v, slice) for slice=slices]
end

"""
$(TYPEDSIGNATURES)
Partition via a inclusive step range over a sorted (not necessarily unique) partition vector, `p`.
"""
function part(v::StructVector{T}, r::AbstractRange, p::AbstractVector; check=default_check(T)) where {T<:SeriesBar}
	check && @assert (issorted(v) && issorted(r) && issorted(p))
	slices = (searchsortedfirst(p, r[i]):searchsortedlast(p, r[i+1]) for i=firstindex(r):length(r)-1)
	[view(v, slice) for slice=slices]
end

"""
$(TYPEDSIGNATURES)
Partition by stepping over a sorted partition vector.
"""
function part(v::StructVector{T}, s, p::AbstractVector; partial=true, check=default_check(T)) where {T<:SeriesBar}
	l = partial ? last(p)+s : last(p)
	part(v, first(p):s:l, p; check=check)
end

"""
$(TYPEDSIGNATURES)
Partition by the partition vector `f(v)`.
"""
function part(f::Function, v::StructVector{T}, s; partial=true, check=default_check(T), kwargs...) where {T<:SeriesBar}
	part(v, s, f(v); partial=partial, check=check, kwargs...)
end

"""
$(TYPEDSIGNATURES)
Split timeseries, `v`, into partitions by periodicity `τ`.
Partitions are inclusive on both ends.

If `align` is set, the partitions are aligned to the calendar.
If `partial` is set, partial partitions (both ends) are included.
"""
function part(v::StructVector{T}, τ::Dates.Period, dti::AbstractVector; align=true, partial=true, check=default_check(T)) where {T<:TimeSeriesBar}
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
	part(v, f:τ:l, dti; check=check)
end

"""
$(TYPEDSIGNATURES)
Convenience fallback.
"""
function part(v::StructVector{T}, τ::Dates.Period; align=true, partial=true, check=default_check(T), idxkey=default_index(T)) where {T<:TimeSeriesBar}
	part(v, τ, StructArrays.component(v, idxkey); align=align, partial=partial, check=check)
end

# """
# $(TYPEDSIGNATURES)
# Convenience fallback.
# Method requires trait: `HasSingleIndex`
# """
# function part(v::StructVector{T}, τ::Dates.Period; align=true, partial=true, check=default_check(T)) where {T<:TimeSeriesBar; HasSingleIndex{T}}
# 	part(v, τ, index(v); align=align, partial=partial, check=check)
# end

