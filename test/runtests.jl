using Langdock
using Test
using HTTP
using JSON3

@testset "Langdock" begin 
    @testset "Types" begin 
        include("types/provider.jl")
        include("types/assistant_config.jl")
    end 

    @testset "API" begin 
        include("api/request.jl")
        include("api/embeddings.jl")
        include("api/assistants.jl")
    end

end

