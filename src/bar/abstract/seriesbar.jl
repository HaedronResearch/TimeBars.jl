"""
$(TYPEDEF)
An `IndexedBar` where the index is ordinal / sequential.

Conditions that must be true for `StructArray{<:SeriesBar}` validity (in addition to all inherited conditions from the parent bar):
* index is sequential (sortable)
"""
abstract type SeriesBar <: IndexedBar end

"""
$(TYPEDSIGNATURES)
Check if an object is a valid `StructArray{<:SeriesBar}`.

See `SeriesBar` for conditions that must be true for validity.
"""
Base.isvalid(arr::StructArray{<:SeriesBar}) = invoke(Base.isvalid, Tuple{StructArray{<:supertype(SeriesBar)}}, arr) && issorted(arr |> TimeBars.index)

"""
$(TYPEDSIGNATURES)
`Base.isless` for `SeriesBar`, enables default sorting.
The index type of `SeriesBar` must define `<` or `isless`.
Defining this method enables sortability for SeriesBars.
"""
Base.isless(a::SeriesBar, b::SeriesBar) = TimeBars.index(a) < TimeBars.index(b)

"""
$(TYPEDSIGNATURES)
XXX Lag a series, does not pre-sort by default
"""
function lag(arr::StructArray{<:SeriesBar}, n::Integer=1; sorted=false, default=ShiftedArrays.default(arr))
	ShiftedArrays.lag(sorted ? sort(arr; dims=1) : arr, n)
end

"""
$(TYPEDSIGNATURES)
XXX Lead a series, does not pre-sort by default
"""
function lead(arr::StructArray{<:SeriesBar}, n::Integer=1; sorted=false, default=ShiftedArrays.default(arr))
	ShiftedArrays.lead(sorted ? sort(arr; dims=1) : arr, n)
end

"""
$(TYPEDSIGNATURES)
Default Impute.jl chain.
"""
@inline default_imputer(::Type{<:SeriesBar}) = Impute.Interpolate() ∘ Impute.NOCB() ∘ Impute.LOCF()

"""
$(TYPEDSIGNATURES)
Check if a series of bars has a regular frequency.
This is the base method that diffs the index and checks if all the increments are equal.
"""
function isregular(arr::StructArray{<:SeriesBar}; sorted=false)
	idx = TimeBars.index(arr)
	diff(sorted ? sort(idx; dims=1) : idx; dims=1) |> allequal
end

"""
$(TYPEDSIGNATURES)
Downsamples the bars.
Maps each index to a partition, then selects a representative from each partition.
This method uses `part` to partition indices and reduces each partition with `sel`.
"""
function downsample(arr::StructArray{<:SeriesBar}; part::Function=ceil, sel::Function=last)
	λ = PartitionBy(part∘TimeBars.index) |> Map(sel)
	copy(λ, StructArray, arr)
end

"""
$(TYPEDSIGNATURES)
This method uses `part(index, τ)` to partition indices and reduces each partition with `sel`.
"""
function downsample(arr::StructArray{<:SeriesBar}, τ; part::Function=ceil, sel::Function=last)
	λ = PartitionBy(x->part(TimeBars.index(x), τ)) |> Map(sel)
	copy(λ, StructArray, arr)
end

