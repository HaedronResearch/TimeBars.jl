"""
$(TYPEDSIGNATURES)
Produce a `NamedTuple` equivalent StructArray from a `StructArray{<:Bar}`.
Handy for working with `Missing` values when the `<:Bar` type disallows them.
"""
function StructArray{NamedTuple}(bars::StructArray{<:Bar}; allowmissings=true)
	nt = StructArrays.components(bars)
	allowmissings && (nt = NamedTuple{keys(nt)}(allowmissing.(values(nt))))
	StructArray(nt)
end

"""
$(TYPEDSIGNATURES)
Produce a `StructArray{<:Bar}` from a `StructArray{<:NamedTuple}`.
Handy for working with `Missing` values when the `<:Bar` type disallows them.
"""
function StructArray{T}(sa::StructArray{<:NamedTuple}; disallowmissings=true) where {T<:Bar}
	nt = StructArrays.components(sa)
	disallowmissings && (nt = NamedTuple{keys(nt)}(disallowmissing.(values(nt))))
	StructArray{T}(nt)
end

"""
$(TYPEDSIGNATURES)
Construct a `StructArray{<:NamedTuple}`, where only the provided `data` are defined and the rest are undefined.

This is not a `StructArray{<:NamedTuple}` constructor because we want to avoid type piracy.
"""
function emptysa(::Type{T}, data::Pair{Symbol, <:AbstractArray}...) where {T<:NamedTuple}
	arr = StructArray{T}(undef, size(last(first(data))))
	for (k,v) in data
		getproperty(arr, k) .= v
	end
	arr
end

@inline findgaps(idx::AbstractVector, τ) = findall(x->x>τ, diff(idx))

@inline function index_range(edges::Pair, τ; excl_f=true, excl_l=true)
	(first(edges)+τ*excl_f):τ:(last(edges)-τ*excl_l)
end

"""
$(TYPEDSIGNATURES)
Expand inner index range.
Assumes single index bar type.
"""
function expandinner!(sv::StructVector{T}, τ, gaps::AbstractVector{<:Integer}; idxkey) where {T<:NamedTuple}
	offset = 0
	for gap in gaps
		realgap = gap + offset
		idxseg = getproperty(sv, idxkey)[realgap:realgap+1]
		newidx = index_range(first(idxseg)=>last(idxseg), τ)
		newrows = emptysa(T, idxkey=>newidx)
		for (i, newrow) in enumerate(newrows)
			insert!(sv, realgap+i, newrow)
		end
		offset += length(newidx)
	end
	sv
end

"""
$(TYPEDSIGNATURES)
Expand outer index range.
Assumes single index bar type.
"""
function expandouter(sv::StructVector{T}, τ, to::Pair; idxkey) where {T<:NamedTuple}
	idx = getproperty(sv, idxkey)
	if first(to) < first(idx)
		newidx = index_range(first(to)=>first(idx), τ; excl_f=false)
		sv = vcat(emptysa(T, idxkey=>newidx), sv)
	end
	if last(idx) < last(to)
		newidx = index_range(last(idx)=>last(to), τ; excl_l=false)
		sv = vcat(sv, emptysa(T, idxkey=>newidx))
	end
	sv
end

"""
$(TYPEDSIGNATURES)
Fallback imputation method.
Assumes single index bar type.

## Steps
1. Convert to `StructArray{<:NamedTuple}` to allow working with `Missing` values.
2. Expands gaps within the index with the periodicity / increment `τ`.
3. Expands index to the range `to`, if provided.
4. Imputation, by default via Impute.Chain: linear interpolation → last observation carried forward (locf) → next observation carried backward (nocb)
5. Convert back to `StructVector{<:SeriesBar}`.
"""
function impute(bars::StructVector{T}, τ, to::Union{Pair,Nothing}=nothing, imputer=default_imputer(T); idxkey=default_index(T)) where {T<:SeriesBar}
	gaps = findgaps(getproperty(bars, idxkey), τ)
	sa = StructArray{NamedTuple}(bars; allowmissings=true)
	sa = expandinner!(sa, τ, gaps; idxkey=idxkey)
	!isnothing(to) && (sa = expandouter(sa, τ, to; idxkey=idxkey))
	StructArray{T}(imputer(sa); disallowmissings=true)
end

