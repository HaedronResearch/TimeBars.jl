@stable findgaps(idx::AbstractVector, τ) = findall(>(τ), diff(idx))

@stable function index_range(edges::Pair, τ; excl_f=true, excl_l=true)
	(first(edges)+τ*excl_f):τ:(last(edges)-τ*excl_l)
end

"""
$(TYPEDSIGNATURES)
Expand inner index range.
Assumes single index bar type.
"""
@stable function expandinner!(sv::StructVector{T}, τ, gaps::AbstractVector{<:Integer}; idxkey) where {T<:NamedTuple}
	offset = 0
	for gap in gaps
		realgap = gap + offset
		idxseg = StructArrays.component(sv, idxkey)[realgap:realgap+1]
		newidx = index_range(first(idxseg)=>last(idxseg), τ)
		newrows = emptysa(T, idxkey=>newidx)
		for (i, newrow) in enumerate(newrows)
			insert!(sv, realgap+i, newrow)
		end
		offset += length(newidx)
	end
	sv
end

"""
$(TYPEDSIGNATURES)
Expand outer index range.
Assumes single index bar type.
"""
@stable function expandouter(sv::StructVector{T}, τ, to::Pair; idxkey) where {T<:NamedTuple}
	idx = StructArrays.component(sv, idxkey)
	if first(to) < first(idx)
		newidx = index_range(first(to)=>first(idx), τ; excl_f=false)
		sv = vcat(emptysa(T, idxkey=>newidx), sv)
	end
	if last(idx) < last(to)
		newidx = index_range(last(idx)=>last(to), τ; excl_l=false)
		sv = vcat(sv, emptysa(T, idxkey=>newidx))
	end
	sv
end

"""
$(TYPEDSIGNATURES)
Do not expand outer index range. Used for dispatch.
"""
@stable expandouter(sa::StructArray, ::Any, ::Nothing; kwargs...) = sa

"""
$(TYPEDSIGNATURES)
Fallback imputation method.
Assumes single index bar type.

## Steps
1. Convert to `StructArray{<:NamedTuple}` to allow working with `Missing` values.
2. Expands gaps within the index with the periodicity / increment `τ`.
3. Expands index to the range `to`, if provided.
4. Imputation, by default via Impute.Chain: linear interpolation → last observation carried forward (locf) → next observation carried backward (nocb)
5. Convert back to `StructVector{<:SeriesBar}`.
"""
@stable function impute(bars::StructVector{T}, τ, to=nothing, imputer=default_imputer(T); idxkey=default_index(T)) where {T<:SeriesBar}
	gaps = findgaps(StructArrays.component(bars, idxkey), τ)
	sa = allowmiss(bars)
	sa = expandinner!(sa, τ, gaps; idxkey=idxkey)
	sa = expandouter(sa, τ, to; idxkey=idxkey)
	sa = Impute.impute(sa, imputer)
	disallowmiss(T, sa)
end

@stable function impute(bars::StructVector{T}, τ, method::Symbol, to=nothing; idxkey=default_index(T), rng=Random.default_rng()) where {T<:SeriesBar}
	if method == :locf
		imp = Impute.LOCF()
	elseif method == :sub
		imp = Impute.Substitute(; statistic=Impute.defaultstats)
	elseif method == :srs
		imp = Impute.SRS(; rng=rng)
	else
		imp = default_imputer(T)
	end
	impute(bars, τ, to, imp; idxkey=idxkey)
end

# struct LocalSRS{R<:AbstractRNG} <: Impute.Imputor
# 	rng::R
# 	n::Int
# end

# LocalSRS(; rng=Random.default_rng(), n=6) = LocalSRS(rng, n)

# function _impute!(data::AbstractVector{Union{T, Missing}}, imp::LocalSRS) where T
# 	obs_values = collect(skipmissing(data))
# 	if !isempty(obs_values)
# 		for i in eachindex(data)
# 			if ismissing(data[i])
# 				flim = max(firstindex(obs_values),i-(imp.n÷2))
# 				llim = min(lastindex(obs_values),i+(imp.n÷2))
# 				data[i] = rand(imp.rng, obs_values[flim, llim])
# 			end
# 		end
# 	end

# 	return data
# end
