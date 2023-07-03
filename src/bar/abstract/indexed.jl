"""
$(TYPEDEF)
A `Bar` with a unique index,
i.e. https://en.wikipedia.org/wiki/Indexed_family

Conditions that must be true for `StructArray{<:IndexedBar}` validity (in addition to all inherited conditions from the parent bar):
* has a subset of values that act as a unique index for the bar
* bar equality is checked by index instead over values (implicit)
"""
abstract type IndexedBar <: Bar end

"""
$(TYPEDSIGNATURES)
Get the index of an `IndexedBar`.
User subtypes of `IndexedBar` must specialize this method,
i.e. `index(bar::MyIndexedBar})` must be implemented.

For single-valued indices, should return the index value.
For multi-valued indices, should return a NamedTuple.
"""
index(bar::IndexedBar) = index(bar)

"""
$(TYPEDSIGNATURES)
Get the index of a `StructArray{<:IndexedBar}`.
User subtypes of `IndexedBar` must specialize this method,
i.e. `index(arr::StructArray{<:MyIndexedBar})` must be implemented.

For single-valued indices, should return the index field of the StructArray.
For multi-valued indices, should return a StructArray{<:NamedTuple}.
"""
index(arr::StructArray{<:IndexedBar}) = index(arr)

"""
$(TYPEDSIGNATURES)
Defines `Base.==` equality for `IndexedBar`,
Overrides equality to be over indices only (see `IndexedBar` for details).
Affects downstream generic Base methods, Base.{allequal, allunique, ...}
"""
Base.:(==)(a::IndexedBar, b::IndexedBar) = index(a) == index(b)

"""
$(TYPEDSIGNATURES)
`Base.unique!` for `StructArray{<:IndexedBar}`.
Deduplicates based on the index only.
This method does not actually use the `IndexedBar` `==` method, it is faster to map to the index first and then deduplicate.
"""
Base.unique!(arr::StructArray{<:IndexedBar})::StructArray = unique!(SeriesBars.index, arr)

"""
$(TYPEDSIGNATURES)
`Base.unique` for `StructArray{<:IndexedBar}`.
Deduplicates based on the index only.
Had to overload unique because normal `Base.unique` returns the wrong container type.
This method does not actually use the `IndexedBar` `==` method, it is faster to map to the index first and then deduplicate.
"""
Base.unique(arr::StructArray{<:IndexedBar})::StructArray = unique(SeriesBars.index, arr)

# """
# $(TYPEDSIGNATURES)
# `Base.unique` for `StructArray{<:IndexedBar}`.
# Deduplicates based on the index only.
# This implementation is cleaner (depends on equality definiton of ==(a::IndexedBar, b::IndexedBar), but slower than the first overload of Base.unique above.
# Relying on the == method for dedup insead of unique(index,...) probably doesnt vectorize as efficiently.
# """
# Base.unique(arr::StructArray{<:IndexedBar})::StructArray = invoke(unique, Tuple{AbstractArray}, arr)

"""
$(TYPEDSIGNATURES)
Check if a type validly implements `IndexedBar`,
e.g. `@assert isvalid(IndexedBar, MyIndexedBar)`.
"""
Base.isvalid(::Type{<:IndexedBar}, T::Type)::Bool = T<:IndexedBar && hasmethod(index, Tuple{T})

"""
$(TYPEDSIGNATURES)
Check if a type validly implements `StructArray{<:IndexedBar}`,
e.g. `@assert isvalid(StructArray{<:IndexedBar}, StructArray{<:MyIndexedBar})`.
"""
Base.isvalid(::Type{<:StructArray{<:IndexedBar}}, T::Type)::Bool = T<:StructArray{<:IndexedBar} && hasmethod(index, Tuple{<:T})

"""
$(TYPEDSIGNATURES)
Check if an object is a valid `StructArray{<:IndexedBar}`.

See `IndexedBar` for conditions that must be true for validity.
"""
Base.isvalid(arr::StructArray{<:IndexedBar}) = invoke(Base.isvalid, Tuple{StructArray{<:supertype(IndexedBar)}}, arr) && allunique(arr)

#"""
# XXX We would like constraints enforced at construction instead of just being able
# to check validity...
#"""
# function StructArrays.StructArray{T}(args...; kwargs...) where T<:IndexedBar
# 	sa = StructArray{T}(args; kwargs)
# 	@assert isvalid(sa)
# 	sa
# end

