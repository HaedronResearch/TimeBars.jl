
"""
$(TYPEDEF)
$(TYPEDFIELDS)
A concrete open, high, low, close (OHLC) Bar implementation.
We use one-letter abbreviations to not conflict with Base.{open, close}.
"""
struct OHLCBar{Idx<:Dates.AbstractDateTime,P<:AbstractFloat} <: TimeTypeBar{Idx}
	dt::Idx
	o::P
	h::P
	l::P
	c::P
end

"""
$(TYPEDSIGNATURES)
"""
TimeBars.index(bar::OHLCBar) = bar.dt    # required by IndexedBar
o(bar::OHLCBar) = bar.o         #
h(bar::OHLCBar) = bar.h         #
l(bar::OHLCBar) = bar.l         #
c(bar::OHLCBar) = bar.c         #

"""
$(TYPEDSIGNATURES)
"""
TimeBars.index(arr::StructArray{<:OHLCBar}) = arr.dt    # required by IndexedBar
o(arr::StructArray{<:OHLCBar}) = arr.o         #
h(arr::StructArray{<:OHLCBar}) = arr.h         #
l(arr::StructArray{<:OHLCBar}) = arr.l         #
c(arr::StructArray{<:OHLCBar}) = arr.c         #

@assert isvalid(OHLCBar) # basic validation of our Bar type
# calling isvalid on array values at runtime (e.g. isvalid(::StructArray{OHLCBar}) verifies more in-depth properties than calling it on the type at declare time (but is also more expensive)

"""
$(TYPEDSIGNATURES)
Aggregate (downsample) a set of OHLCBars
"""
function agg(arr::StructArray{<:OHLCBar})
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

