module TimeBars

using Dates
using Random
using PrettyTables
using ShiftedArrays
using StructArrays
using Missings
using Impute
using DispatchDoctor
using MovingWindowsBase
import Printf: @sprintf
import DocStringExtensions: TYPEDEF, TYPEDFIELDS, TYPEDSIGNATURES

export Bar, IndexedBar, SeriesBar, TimeSeriesBar, TimeTypeBar
export impute, index, lag, lead, part, regularity, roll, slide
public imputer

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

# MovingWindowsBase overrides
include("methods/mwbase/regularity.jl")
include("methods/mwbase/roll.jl")
include("methods/mwbase/slide.jl")

include("methods/impute.jl")
include("methods/index.jl")
include("methods/laglead.jl")
include("methods/part.jl")

end
