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
		# setproperty!(arr, k, v)
	end
	arr
end
