
"""
$(TYPEDEF)
$(TYPEDFIELDS)
"""
struct OHLCBar{Idx<:Dates.AbstractDateTime,P<:AbstractFloat} <: TimeTypeBar{Idx}
	dt::Idx
	open::P
	high::P
	low::P
	close::P
end

index(bar::OHLCBar) = bar.dt # required
open(bar::OHLCBar) = bar.open
high(bar::OHLCBar) = bar.high
low(bar::OHLCBar) = bar.low
close(bar::OHLCBar) = bar.close

index(arr::StructArray{<:OHLCBar}) = arr.dt # required
open(arr::StructArray{<:OHLCBar}) = arr.open
high(arr::StructArray{<:OHLCBar}) = arr.high
low(arr::StructArray{<:OHLCBar}) = arr.low
close(arr::StructArray{<:OHLCBar}) = arr.close

# Tables.istable(::Type{MyTable})

# function subset(arr::AbstractVector{<:TimeSeriesBar})
# end

"""
$(TYPEDSIGNATURES)
Aggregate (downsample) a set of OHLCBars
"""
function agg(arr::AbstractArray{<:OHLCBar})
	OHLCBar(
		last(index(arr)),
		first(open(arr)),
		maximum(high(arr)),
		minimum(low(arr)),
		last(close(arr))
	)
end

"""
$(TYPEDSIGNATURES)
This method uses `part(index, τ)` to partition indices and aggregates each partition with `agg`.

`collect` selects wrong container for structArrays: https://github.com/JuliaFolds/Transducers.jl/issues/532
Once this is fixed, alloc can go way down.
"""
function downsample(arr::StructArray{<:OHLCBar}, τ::Dates.Period; part::Function=ceil)::StructArray
	# λ = PartitionBy(x->part(index(x), τ)) |> Map(agg)
	# copy(λ, StructArray{OHLCBar}, arr)
	arr |> PartitionBy(x->part(index(x),τ)) |> Map(agg) |> collect
end

