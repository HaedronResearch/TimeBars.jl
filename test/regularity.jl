
@testset "regularity" begin
	let τ=Minute(1), τ2=Millisecond(30_000), d=DateTime(2020)
		@assert τ > τ2
		@test regularity(DateTime[], τ) == 1.0
		@test regularity(DateTime[d], τ) == 1.0
		@test regularity(DateTime[d, d+τ, d+2τ, d+3τ], τ) == 1.0
		@test regularity(DateTime[d, d+τ, d+2τ, d+3τ], τ) == 1.0
		@test regularity(DateTime[d, d+3τ], τ) == 0.5
		@test regularity(DateTime[d, d+τ2, d+3τ], τ) == 0.5
		@test regularity(DateTime[d, d+3τ2, d+3τ], τ) == 0.75
		@test regularity(DateTime[d, d+3τ], 10τ) == 1.0
	end
end
