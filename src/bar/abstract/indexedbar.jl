"""
$(TYPEDEF)
A `Bar` with a unique index,
i.e. https://en.wikipedia.org/wiki/Indexed_family

Conditions that must be true for `StructArray{<:IndexedBar}` validity (in addition to all inherited conditions from the parent bar):
* has a subset of values (column(s)) that act as a unique index for the bar
* the index is either a non-StructArray AbstractArray or a StructArray{<:NamedTuple}
* `TimeBars.index` methods are defined, see `TimeBars.index` for details
* bar equality is checked by index instead over values (implicit)
* bar uniqueness is checked by index instead over values (implicit)
"""
abstract type IndexedBar <: Bar end

"""
$(TYPEDSIGNATURES)
Check if a type validly implements `IndexedBar`,
e.g. `@assert isvalid(IndexedBar, MyBar)`.
"""
function Base.isvalid(P::Type{<:IndexedBar}, T::Type)
	parcond = invoke(Base.isvalid, Tuple{Type{<:supertype(IndexedBar)}, Type}, P, T)
	parcond && hasmethod(TimeBars.index, Tuple{<:T}) && hasmethod(TimeBars.index, Tuple{<:StructArray{<:T}})
end

"""
$(TYPEDSIGNATURES)
Check if an object is a valid `StructArray{<:IndexedBar}`.

See `IndexedBar` for conditions that must be true for validity.
"""
function Base.isvalid(arr::StructArray{<:IndexedBar})
	parcond = invoke(Base.isvalid, Tuple{StructArray{<:supertype(IndexedBar)}}, arr)
	idx = arr |> TimeBars.index
	it = idx |> typeof
	parcond && ((!(it <: StructArray) && it <: AbstractArray) || it <: StructArray{<:NamedTuple}) && allunique(idx)
end

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
# index(bar::IndexedBar) = index(bar)

"""
$(TYPEDSIGNATURES)
Default single index name.
"""
@inline default_index(::Type{<:IndexedBar}) = :idx

# """
# $(TYPEDSIGNATURES)
# Get the index of a `StructArray{<:IndexedBar}`.
# User subtypes of `IndexedBar` must specialize this method,
# i.e. `index(arr::StructArray{<:MyIndexedBar})` must be implemented.

# For single-valued indices, should return the index field of the StructArray.
# For multi-valued indices, should return a StructArray{<:NamedTuple}.
# """
# index(arr::StructArray{<:IndexedBar}) = index(arr)

# """
# $(TYPEDSIGNATURES)
# Display method for `StructVector{<:IndexedBar}` table.
# TODO want the index columns to be bolded, underlined, or something.
# """
# function Base.show(io::IO, ::MIME"text/plain", bars::StructArrays.StructVector{T}; tf=tf_ascii_dots) where {T<:IndexedBar}
# 	title = @sprintf "StructVector{%s} of %.3g IndexedBars" nameof(T) length(bars)
# 	pretty_table(io, StructArrays.components(bars);
# 		tf=tf,
# 		title=title,
# 		crop=:vertical,
# 		vcrop_mode=:middle,
# 		show_header=true,
# 		show_subheader=true,
# 		show_omitted_cell_summary=false,
# 	)
# end

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

# """
# $(TYPEDSIGNATURES)
# `Base.unique` for `StructArray{<:IndexedBar}`.
# Deduplicates based on the index only.
# This implementation is cleaner (depends on equality definiton of ==(a::IndexedBar, b::IndexedBar), but slower than the first overload of Base.unique above.
# Relying on the == method for dedup insead of unique(index,...) probably doesnt vectorize as efficiently.
# """
# Base.unique(arr::StructArray{<:IndexedBar})::StructArray = invoke(unique, Tuple{AbstractArray}, arr)

