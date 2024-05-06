"""
Quantify the regularity of a DateTime index at minimum frequency `τ`,
the ratio of existing DateTimes to the theoretical maximum (`1.0`) between the first and last (inclusive) DateTime.
This method cannot return `0.0` because a single or empty DateTime index will always return regularity of `1.0`.
"""
function regularity(v::AbstractVector{DateTime}, τ::Period; check=false)
	check && @assert issorted(v)
	isempty(v) && return 1.
	full = round(v[end] - v[begin], τ) + τ
	gaps = filter(>(τ), diff(v))
	miss = round(sum(gaps), τ) - length(gaps) * τ
	(full - miss) / full
end

"""
$(TYPEDSIGNATURES)
"""
function regularity(bars::StructVector{T}, τ::Period; idxkey=default_index(T), check=default_check(T)) where {T<:TimeTypeBar}
	regularity(StructArrays.component(bars, idxkey), τ)
end
