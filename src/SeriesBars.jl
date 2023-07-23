module SeriesBars

using Dates
using ShiftedArrays
using StructArrays
using Transducers
using DocStringExtensions: TYPEDEF, TYPEDFIELDS, TYPEDSIGNATURES

include("bar/abstract/bar.jl")
include("bar/abstract/indexedbar.jl")
include("bar/abstract/seriesbar.jl")
include("bar/abstract/timeseriesbar.jl")
include("bar/abstract/timetypebar.jl")
include("bar/concrete/ohlcbar.jl")

export TimeTypeBar
export OHLCBar
export index, lag, lead, isregular, downsample

end
