"""
$(TYPEDSIGNATURES)
Lag: remove last `n` and shift down by `n`.
If `n` is an integer, dimensions after the first are not shifted.
"""
function lag(arr::StructArray{T}, n=1; check=default_check(T), default=ShiftedArrays.default(arr)) where {T<:SeriesBar}
	check && @assert issorted(arr)
	ShiftedArrays.lag(arr, n; default=default)
end

"""
$(TYPEDSIGNATURES)
Lead: remove first `n` and shift up by `n`.
If `n` is an integer, dimensions after the first are not shifted.
"""
function lead(arr::StructArray{T}, n=1; check=default_check(T), default=ShiftedArrays.default(arr)) where {T<:SeriesBar}
	check && @assert issorted(arr)
	ShiftedArrays.lead(arr, n; default=default)
end
