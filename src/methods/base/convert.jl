"""
$(TYPEDSIGNATURES)
Convert between `StructArray{<:Bar}` with different concrete `Bar`s.

Will not work (throws error) if (pseudocode): fields(S) ⊆ fields(T),
i.e. fields of the source must be a superset of fields of the target
(same names and compatible types).

Probably just as good if `{T<:Any, S<:Any}` however we want to avoid type piracy.
"""
Base.convert(::Type{<:StructArray{T}}, bars::StructArray{S}) where {T<:Bar, S<:Bar} = Base.convert(T, bars)

"""
$(TYPEDSIGNATURES)
Convert between `StructArray{<:Bar}` with different concrete `Bar`s.

Will not work (throws error) if (pseudocode): fields(S) ⊆ fields(T),
i.e. fields of the source must be a superset of fields of the target
(same names and compatible types).

Probably just as good if `{T<:Any, S<:Any}` however we want to avoid type piracy.
"""
function Base.convert(::Type{T}, bars::StructArray{S}) where {T<:Bar, S<:Bar}
	(isstructtype(T) && isstructtype(S)) || throw(ArgumentError("Bar types must be struct types"))
	StructArray{T}(StructArrays.components(bars))
end
