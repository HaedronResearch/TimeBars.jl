"""
$(TYPEDEF)
A labeled row/struct/set of values, like a NamedTuple.

Conditions that must be true for `StructArray{<:Bar}` validity:
* unique label / position per value in a `Bar` (implicit from `StructArray`)
"""
abstract type Bar end

"""
$(TYPEDSIGNATURES)
Check if a type validly implements `Bar`,
e.g. `@assert isvalid(Bar, MyBar)`.
"""
Base.isvalid(P::Type{<:Bar}, T::Type) = T<:P

"""
$(TYPEDSIGNATURES)
Check if a Bar type `T` validly implements supertype(T).
"""
Base.isvalid(T::Type{<:Bar}) = isvalid(supertype(T), T)

"""
$(TYPEDSIGNATURES)
Check if an object is a valid `StructArray{<:Bar}`.

See `Bar` for conditions that must be true for validity.
"""
Base.isvalid(arr::StructArray{<:Bar}) = true

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
	isconcretetype(T) && isconcretetype(S) || throw(ArgumentError("Bar types must be concrete"))
	StructArray{T}(StructArrays.components(bars))
end

# """
# $(TYPEDSIGNATURES)
# Wraps StructArray{<:Bar} constructor in order to apply runtime asserts after construction. These asserts can be turned off by setting the `validatebars` keyword argument `false`.
# TODO
# """
# function StructArrays.StructArray{T}(args...; validatebars=true, kwargs...) where T<:Bar
# 	sa = @invoke StructArrays.StructArray{T}(arg::Any; kwargs...)
# 	validatebars && @assert isvalid(sa) # uses most specialized isvalid method
# 	sa
# end

# """
# $(TYPEDSIGNATURES)
# Wraps StructArray{<:Bar} constructor in order to apply runtime asserts after construction. These asserts can be turned off by setting the `validatebars` keyword argument `false`.
# TODO
# """
# function StructArrays.StructArray{T}(c::C; validatebars=true, kwargs...) where {T<:Bar, C<:Union{Tuple, NamedTuple}}
# 	sa = StructArrays.StructArray{T}(c; kwargs...)
# 	validatebars && @assert isvalid(sa) # uses most specialized isvalid method
# 	sa
# end
