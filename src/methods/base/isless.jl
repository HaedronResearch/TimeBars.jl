"""
$(TYPEDSIGNATURES)
`Base.isless` for `SeriesBar`, enables default sorting.
The index type of `SeriesBar` must define `<` or `isless`.
Defining this method enables sortability for SeriesBars.
"""
Base.isless(a::SeriesBar, b::SeriesBar) = TimeBars.index(a) < TimeBars.index(b)
