"""
$(TYPEDSIGNATURES)
"""
function MovingWindowsBase.regularity(bars::StructVector{T}, τ::Period; idxkey=default_index(T), check=default_check(T)) where {T<:TimeTypeBar}
	regularity(StructArrays.component(bars, idxkey), τ; check=check)
end

# """
# $(TYPEDSIGNATURES)
# # Method requires trait: `HasSingleIndex`
# """
# function regularity(bars::StructVector{T}, τ::Period; check=default_check(T)) where {T<:TimeTypeBar; HasSingleIndex{T}}
# 	regularity(index(bars), τ)
# end
