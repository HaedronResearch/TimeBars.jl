
"""
$(TYPEDEF)
$(TYPEDFIELDS)
A concrete open, high, low, close (OHLC) Bar implementation.
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
TimeBars.index(bar::OHLCBar) = bar.dt                       # required by IndexedBar
TimeBars.index(arr::StructArray{<:OHLCBar}) = arr.dt        # required by IndexedBar
@assert isvalid(OHLCBar) # basic validation of our Bar type
# calling isvalid on array values at runtime (e.g. isvalid(::StructArray{OHLCBar}) verifies more in-depth properties than calling it on the type at declare time (but is also more expensive)

# accessors, not required for validity but useful to have:
o(bars::Union{OHLCBar, StructArray{<:TulipBar}}) = bars.o
h(bars::Union{OHLCBar, StructArray{<:TulipBar}}) = bars.h
l(bars::Union{OHLCBar, StructArray{<:TulipBar}}) = bars.l
c(bars::Union{OHLCBar, StructArray{<:TulipBar}}) = bars.c

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

