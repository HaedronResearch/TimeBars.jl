module TimeBars

using Dates
using Printf
using PrettyTables
using ShiftedArrays
using StructArrays
using Transducers
using Missings
using Impute
using DocStringExtensions: TYPEDEF, TYPEDFIELDS, TYPEDSIGNATURES

export TimeSeriesBar, TimeTypeBar
export index, lag, lead, isregular, downsample, parts
export impute

include("bar/abstract/bar.jl")
include("bar/abstract/indexedbar.jl")
include("bar/abstract/seriesbar.jl")
include("bar/abstract/timeseriesbar.jl")
include("bar/abstract/timetypebar.jl")
# include("bar/concrete/ohlcbar.jl")

include("ext/impute.jl")

end
