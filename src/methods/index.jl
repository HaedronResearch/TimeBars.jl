"""
$(TYPEDSIGNATURES)
Get the index of an `IndexedBar`.
User subtype `MyIndexedBar <: IndexedBar` must implement the following to be valid:
* `TimeBars.index(bar::MyIndexedBar)`
* `TimeBars.index(arr::StructArray{<:MyIndexedBar})`

For single-valued indices, should return the index value.
For multi-valued indices, should return a NamedTuple.
"""
function index end
