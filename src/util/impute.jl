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

@inline linear_interpolate(m, b, r::UnitRange) = [m*x+b for x=r]

function index_interpolate(edges::Pair, τ)
	f, l = edges
	n = (l - f) ÷ τ - 1
	linear_interpolate(τ, f, 1:n)
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
		newidx = index_interpolate(first(idxseg)=>last(idxseg), τ)
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
	prep, app = nothing, nothing
	if first(to) < first(idx)
		newidx = index_interpolate(first(to)=>first(idx), τ)
		sv = vcat(emptysa(T, idxkey=>newidx), sv)
	end
	if last(idx) < last(to)
		newidx = index_interpolate(last(idx)=>last(to), τ)
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

