"""
$(TYPEDSIGNATURES)
Default runtime assertion checks.
"""
@inline default_check(::Type{<:Bar}) = false
