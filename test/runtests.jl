using Test
using Dates
using StructArrays
using TimeBars

# include("aqua.jl")

include("regularity.jl")

# ohlc = StructArray{TimeBars.OHLCBar}((DateTime.(1:100), 1:1:100, 1:1:100, 1:1:100, 1:1:100))

# @show ohlc
# let dn = downsample(ohlc, Year(10))
	# @test typeof(dn) <: StructArray
# end
