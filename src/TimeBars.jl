module TimeBars

using Dates
using PrettyTables
using ShiftedArrays
using StructArrays
using Missings
using Impute
import Printf: @sprintf
import DocStringExtensions: TYPEDEF, TYPEDFIELDS, TYPEDSIGNATURES

export Bar, IndexedBar, SeriesBar, TimeSeriesBar, TimeTypeBar
export impute, index, lag, lead, parts, regularity

include("types/bars.jl")

include("defaults/check.jl")
include("defaults/impute.jl")
include("defaults/index.jl")

include("util/namedtuple.jl")

# Base overrides
include("methods/base/convert.jl")
include("methods/base/isvalid.jl")
include("methods/base/show.jl")
include("methods/base/isless.jl")   # enables Base.sort
include("methods/base/unique.jl")

include("methods/impute.jl")
include("methods/index.jl")
include("methods/laglead.jl")
include("methods/parts.jl")
include("methods/regularity.jl")

end
