"""
$(TYPEDSIGNATURES)
Roll `f` over each τ-window of `sel(bars)`
"""
function MovingWindowsBase.roll(f::Function, sel::Function, v::StructVector{T}, τ; check=default_check(T)) where {T<:SeriesBar}
	roll(f, index(v)=>sel(v), τ; check=check)
end
