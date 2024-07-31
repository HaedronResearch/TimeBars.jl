"""
$(TYPEDSIGNATURES)
Slide `f` over each τ-window of `sel(bars)`
"""
function MovingWindowsBase.slide(f::Function, sel::Function, v::StructVector{T}, τ; check=default_check(T)) where {T<:SeriesBar}
	slide(f, index(v)=>sel(v), τ; check=check)
end
