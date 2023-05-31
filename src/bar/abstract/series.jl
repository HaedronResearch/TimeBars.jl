"""
$(TYPEDEF)
An IndexedBar where the index is ordinal / sequential.
(i.e. an indexed family: https://en.wikipedia.org/wiki/Indexed_family)
"""
abstract type SeriesBar <: IndexedBar end

"$(TYPEDSIGNATURES)"
index(bar::SeriesBar) = index(bar)

"$(TYPEDSIGNATURES)"
index(arr::StructArray{<:SeriesBar}) = index(arr)

"""
$(TYPEDSIGNATURES)
Base.isless for `SeriesBar`, enables default sorting.
The index of `SeriesBar` must define `<` or `isless`.
"""
Base.isless(a::SeriesBar, b::SeriesBar) = index(a) < index(b)

"""
$(TYPEDSIGNATURES)
Lag a series, does not pre-sort by default
"""
function lag(arr::StructArray{<:SeriesBar}, n::Integer=1; sorted=false, default=ShiftedArrays.default(arr))
	ShiftedArrays.lag(sorted ? sort(arr; dims=1) : arr, n)
end

"""
$(TYPEDSIGNATURES)
Lead a series, does not pre-sort by default
"""
function lead(arr::StructArray{<:SeriesBar}, n::Integer=1; sorted=false, default=ShiftedArrays.default(arr))
	ShiftedArrays.lead(sorted ? sort(arr; dims=1) : arr, n)
end

"""
$(TYPEDSIGNATURES)
Check if a series of bars has a regular frequency.
This is the base method that diffs the series and checks if all the elements are equal.
"""
function isregular(arr::StructArray{<:SeriesBar}; sorted=false)
	idx = index(arr)
	diff(sorted ? sort(idx; dims=1) : idx; dims=1) |> allequal
end

"""
$(TYPEDSIGNATURES)
Downsamples the bars.
Maps each index to a partition, then selects a representative from each partition.
This method uses `part` to partition indices and reduces each partition with `sel`.
"""
function downsample(arr::StructArray{<:SeriesBar}; part::Function=ceil, sel::Function=last)
	λ = PartitionBy(part∘index) |> Map(sel)
	copy(λ, StructArray, arr)
end

"""
$(TYPEDSIGNATURES)
This method uses `part(index, τ)` to partition indices and reduces each partition with `sel`.
"""
function downsample(arr::StructArray{<:SeriesBar}, τ; part::Function=ceil, sel::Function=last)
	λ = PartitionBy(x->part(index(x), τ)) |> Map(sel)
	copy(λ, StructArray, arr)
end

