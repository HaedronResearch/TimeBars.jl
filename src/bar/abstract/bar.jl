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
Base.isvalid(::Type{<:Bar}, T::Type)::Bool = T<:Bar

"""
$(TYPEDSIGNATURES)
Check if a type validly implements `StructArray{<:Bar}`,
e.g. `@assert isvalid(StructArray{<:Bar}, StructArray{<:MyBar})`.
"""
Base.isvalid(::Type{<:StructArray{<:Bar}}, T::Type)::Bool = T<:StructArray{<:Bar}

"""
$(TYPEDSIGNATURES)
Check if an object is a valid `StructArray{<:Bar}`.

See `Bar` for conditions that must be true for validity.
"""
Base.isvalid(arr::StructArray{<:Bar}) = true

