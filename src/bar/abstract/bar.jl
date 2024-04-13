"""
$(TYPEDEF)
A labeled row/struct/set of values, like a NamedTuple.

Conditions that must be true for `StructArray{<:Bar}` validity:
* unique label / position per value in a `Bar` (implicit from `StructArray`)
"""
abstract type Bar end

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
Convert between `StructArray{<:Bar}` with different concrete `Bar`s.

Will not work (throws error) if (pseudocode): fields(S) ⊆ fields(T),
i.e. fields of the source must be a superset of fields of the target
(same names and compatible types).

Probably just as good if `{T<:Any, S<:Any}` however we want to avoid type piracy.
"""
Base.convert(::Type{<:StructArray{T}}, bars::StructArray{S}) where {T<:Bar, S<:Bar} = Base.convert(T, bars)

"""
$(TYPEDSIGNATURES)
Convert between `StructArray{<:Bar}` with different concrete `Bar`s.

Will not work (throws error) if (pseudocode): fields(S) ⊆ fields(T),
i.e. fields of the source must be a superset of fields of the target
(same names and compatible types).

Probably just as good if `{T<:Any, S<:Any}` however we want to avoid type piracy.
"""
function Base.convert(::Type{T}, bars::StructArray{S}) where {T<:Bar, S<:Bar}
	isstructtype(T) && isstructtype(S) || throw(ArgumentError("Bar types must be struct types"))
	StructArray{T}(StructArrays.components(bars))
end

"""
$(TYPEDSIGNATURES)
Display method for `StructVector{<:Bar}` table.
"""
function Base.show(io::IO, ::MIME"text/plain", bars::StructArrays.StructVector{T}; tf=tf_ascii_dots) where {T<:Bar}
	title = @sprintf "StructVector{%s} of %.3g Bars" nameof(T) length(bars)
	pretty_table(io, StructArrays.components(bars);
		tf=tf,
		title=title,
		crop=:vertical,
		vcrop_mode=:middle,
		show_omitted_cell_summary=false,
	)
end

"""
$(TYPEDSIGNATURES)
Partition based on (inclusive) integer index cut points.
"""
function parts(v::StructVector{T}, cuts::AbstractVector{<:Integer}; check=false) where {T<:Bar}
	check && @assert (issorted(v) && issorted(cuts) && allunique(cuts))
	slices = (cuts[i]:cuts[i+1] for i=1:length(cuts)-1)
	[@view v[slice] for slice=slices]
end

"""
$(TYPEDSIGNATURES)
Partition via a inclusive step range over a sorted (not necessarily unique) partition vector, `p`.
"""
function parts(v::StructVector{T}, r::AbstractRange, p::AbstractVector; check=false) where {T<:Bar}
	check && @assert (issorted(v) && issorted(r) && issorted(p))
	slices = (searchsortedfirst(p, r[i]):searchsortedlast(p, r[i+1]) for i=1:length(r)-1)
	[@view v[slice] for slice=slices]
end

# """
# $(TYPEDSIGNATURES)
# Wraps StructArray{<:Bar} constructor in order to apply runtime asserts after construction. These asserts can be turned off by setting the `validatebars` keyword argument `false`.
# TODO
# """
# function StructArrays.StructArray{T}(args...; validatebars=true, kwargs...) where T<:Bar
# 	sa = @invoke StructArrays.StructArray{T}(arg::Any; kwargs...)
# 	validatebars && @assert isvalid(sa) # uses most specialized isvalid method
# 	sa
# end

# """
# $(TYPEDSIGNATURES)
# Wraps StructArray{<:Bar} constructor in order to apply runtime asserts after construction. These asserts can be turned off by setting the `validatebars` keyword argument `false`.
# TODO
# """
# function StructArrays.StructArray{T}(c::C; validatebars=true, kwargs...) where {T<:Bar, C<:Union{Tuple, NamedTuple}}
# 	sa = StructArrays.StructArray{T}(c; kwargs...)
# 	validatebars && @assert isvalid(sa) # uses most specialized isvalid method
# 	sa
# end
