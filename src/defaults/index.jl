"""
$(TYPEDSIGNATURES)
Default single index name.
This function will eventually be removed.
"""
@inline default_index(::Type{<:IndexedBar}) = :idx

"""
$(TYPEDSIGNATURES)
Default single index name and time index component name (for multi-valued), for time series bars.
"""
@inline default_index(::Type{<:TimeSeriesBar}) = :dt
