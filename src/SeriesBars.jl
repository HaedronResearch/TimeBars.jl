module SeriesBars

using Dates
using ShiftedArrays
using StructArrays
using Transducers
using DocStringExtensions: TYPEDEF, TYPEDFIELDS, TYPEDSIGNATURES

include("bar/abstract/bar.jl")
include("bar/abstract/indexed.jl")
include("bar/abstract/series.jl")
include("bar/abstract/timeseries.jl")
include("bar/abstract/timetype.jl")
include("bar/concrete/ohlc.jl")

export TimeTypeBar
export index, lag, lead, isregular, downsample

end
