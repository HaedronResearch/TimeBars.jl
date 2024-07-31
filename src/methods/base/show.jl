"""
$(TYPEDSIGNATURES)
Display method for `StructVector{<:Bar}` table.
"""
function Base.show(io::IO, ::MIME"text/plain", bars::StructArrays.StructVector{T}; tf=tf_ascii_dots) where {T<:Bar}
	title = @sprintf "StructVector{%s} of %.3g Bars" nameof(T) length(bars)
	pretty_table(io, StructArrays.components(bars);
		tf=tf,
		title=title,
		alignment=:l,
		crop=:vertical,
		vcrop_mode=:middle,
		show_omitted_cell_summary=false,
	)
end
