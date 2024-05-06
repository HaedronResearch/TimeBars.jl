"""
$(TYPEDSIGNATURES)
Check if a type validly implements `Bar`,
e.g. `@assert isvalid(Bar, MyBar)`.
"""
Base.isvalid(P::Type{<:Bar}, T::Type) = T<:P

"""
$(TYPEDSIGNATURES)
Check if a Bar type `T` validly implements supertype(T).
"""
Base.isvalid(T::Type{<:Bar}) = isvalid(supertype(T), T)

"""
$(TYPEDSIGNATURES)
Check if an object is a valid `StructArray{<:Bar}`.

See `Bar` for conditions that must be true for validity.
"""
Base.isvalid(arr::StructArray{<:Bar}) = true

"""
$(TYPEDSIGNATURES)
Check if a type validly implements `IndexedBar`,
e.g. `@assert isvalid(IndexedBar, MyBar)`.
"""
function Base.isvalid(P::Type{<:IndexedBar}, T::Type)
	parcond = invoke(Base.isvalid, Tuple{Type{<:supertype(IndexedBar)}, Type}, P, T)
	parcond && hasmethod(TimeBars.index, Tuple{<:T}) && hasmethod(TimeBars.index, Tuple{<:StructArray{<:T}})
end

"""
$(TYPEDSIGNATURES)
Check if an object is a valid `StructArray{<:IndexedBar}`.

See `IndexedBar` for conditions that must be true for validity.
"""
function Base.isvalid(arr::StructArray{<:IndexedBar})
	parcond = invoke(Base.isvalid, Tuple{StructArray{<:supertype(IndexedBar)}}, arr)
	idx = arr |> TimeBars.index
	it = idx |> typeof
	parcond && ((!(it <: StructArray) && it <: AbstractArray) || it <: StructArray{<:NamedTuple}) && allunique(idx)
end

"""
$(TYPEDSIGNATURES)
Check if an object is a valid `StructArray{<:SeriesBar}`.

See `SeriesBar` for conditions that must be true for validity.
"""
Base.isvalid(arr::StructArray{<:SeriesBar}) = invoke(Base.isvalid, Tuple{StructArray{<:supertype(SeriesBar)}}, arr) && issorted(arr |> TimeBars.index)

"""
$(TYPEDSIGNATURES)
Check if an object is a valid `StructArray{<:TimeTypeBar}`.

See `TimeTypeBar` for conditions that must be true for validity.
"""
function Base.isvalid(arr::StructArray{<:TimeTypeBar})
	parcond = invoke(Base.isvalid, Tuple{StructArray{<:supertype(TimeTypeBar)}}, arr)
	it = arr |> TimeBars.index |> typeof
	parcond && ((!(it <: StructArray) && it <: AbstractArray{<:TimeType}) || it <: StructArray{<:NamedTuple} && any(it |> eltype |> fieldtypes .<: TimeType))
end
