"""
$(TYPEDSIGNATURES)
Default single index name.
"""
index(::Type{<:IndexedBar}) = :idx

"""
$(TYPEDSIGNATURES)
Default single index name and time index component name (for multi-valued), for time series bars.
"""
index(::Type{<:TimeSeriesBar}) = :dt
