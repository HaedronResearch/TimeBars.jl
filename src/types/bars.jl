"""
$(TYPEDEF)
A labeled row/struct/set of values, like a NamedTuple.

Conditions that must be true for `StructArray{<:Bar}` validity:
* unique label / position per value in a `Bar` (implicit from `StructArray`)
"""
abstract type Bar end

"""
$(TYPEDEF)
A `Bar` with a unique index,
i.e. https://en.wikipedia.org/wiki/Indexed_family

Conditions that must be true for `StructArray{<:IndexedBar}` validity (in addition to all inherited conditions from the parent bar):
* has a subset of values (column(s)) that act as a unique index for the bar
* the index is either a non-StructArray AbstractArray or a StructArray{<:NamedTuple}
* `TimeBars.index` methods are defined, see `TimeBars.index` for details
* bar equality is checked by index instead over values (implicit)
* bar uniqueness is checked by index instead over values (implicit)
"""
abstract type IndexedBar <: Bar end

"""
$(TYPEDEF)
An `IndexedBar` where the index is ordinal / sequential.

Conditions that must be true for `StructArray{<:SeriesBar}` validity (in addition to all inherited conditions from the parent bar):
* index is sequential (sortable)
"""
abstract type SeriesBar <: IndexedBar end

"""
$(TYPEDEF)
A `SeriesBar` where the index is a time series.

Conditions that must be true for `StructArray{<:TimeSeriesBar}` validity (in addition to all inherited conditions from the parent bar):
* index element type is or contains a temporal value

Here we are deliberately abstract/agnostic about what is meant by "temporal value" for the sake of generality, subtypes will enforce what `TimeSeriesBar` actually looks like.
"""
abstract type TimeSeriesBar <: SeriesBar end

"""
$(TYPEDEF)
A `TimeSeriesBar` whose temporal indexing type is a `Dates.TimeType`
(e.g. `Dates.DateTime`, `Dates.Date`, `Dates.Time`).

Conditions that must be true for `StructArray{<:TimeTypeBar}` validity (in addition to all inherited conditions from the parent bar):
* index must be a non-StructArray AbstractArray{<:Dates.TimeType} or a StructArray{<:NamedTuple} with a Dates.TimeType as a field type
"""
abstract type TimeTypeBar{Idx<:Dates.TimeType} <: TimeSeriesBar end
