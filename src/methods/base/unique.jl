"""
$(TYPEDSIGNATURES)
Defines `Base.==` equality for `IndexedBar`,
Overrides equality to be over indices only (see `IndexedBar` for details).
Affects downstream generic Base methods, Base.{allequal, allunique, ...}
"""
Base.:(==)(a::IndexedBar, b::IndexedBar) = TimeBars.index(a) == TimeBars.index(b)

"""
$(TYPEDSIGNATURES)
`Base.unique!` for `StructArray{<:IndexedBar}`.
Deduplicates based on the index only.
This method does not actually use the `IndexedBar` `==` method, it is faster to map to the index first and then deduplicate.
"""
Base.unique!(arr::StructArray{<:IndexedBar})::StructArray = unique!(TimeBars.index, arr)

"""
$(TYPEDSIGNATURES)
`Base.unique` for `StructArray{<:IndexedBar}`.
Deduplicates based on the index only.
Had to overload unique because normal `Base.unique` returns the wrong container type.
This method does not actually use the `IndexedBar` `==` method, it is faster to map to the index first and then deduplicate.
"""
Base.unique(arr::StructArray{<:IndexedBar})::StructArray = unique(TimeBars.index, arr)
