"""
$(TYPEDSIGNATURES)
Default single index name.
"""
@inline default_index(::Type{<:IndexedBar}) = :idx

"""
$(TYPEDSIGNATURES)
Default single index name and time index component name (for multi-valued), for time series bars.
"""
@inline default_index(::Type{<:TimeSeriesBar}) = :dt
