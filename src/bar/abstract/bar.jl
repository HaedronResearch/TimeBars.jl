"""
$(TYPEDEF)
A named row/struct of values, could be represented by a NamedTuple.
"""
abstract type Bar end

"""
$(TYPEDEF)
A bar attached to a unique index.
"""
abstract type IndexedBar <: Bar end

"$(TYPEDSIGNATURES)"
index(bar::IndexedBar) = index(bar)

"$(TYPEDSIGNATURES)"
index(arr::StructArray{<:IndexedBar}) = index(arr)

