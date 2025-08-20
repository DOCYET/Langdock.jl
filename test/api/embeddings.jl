@testset "create_openai_embeddings" begin
    @testset "single input string" begin
        r = Langdock.create_openai_embeddings(ENV["LANGDOCK_API_KEY"], "Hello world.")
        embedding = r.response["data"][begin]["embedding"]
        @test typeof(embedding) <: AbstractVector
        @test eltype(embedding) == Float64
        @test !isempty(embedding)
    end

    @testset "multiple input strings" begin
        r = Langdock.create_openai_embeddings(ENV["LANGDOCK_API_KEY"], ["foo bar", "biz baz"])
        data = r.response["data"]
        @test length(data) == 2

        embedding1 = data[begin]["embedding"]
        @test typeof(embedding1) <: AbstractVector
        @test eltype(embedding1) == Float64
        @test !isempty(embedding1)

        embedding2 = data[end]["embedding"]
        @test typeof(embedding1) <: AbstractVector
        @test eltype(embedding1) == Float64
        @test !isempty(embedding1)
    end

    @testset "single input token array" begin
        r = Langdock.create_openai_embeddings(ENV["LANGDOCK_API_KEY"], [1234, 5678])
        embedding = r.response["data"][begin]["embedding"]
        @test typeof(embedding) <: AbstractVector
        @test eltype(embedding) == Float64
        @test !isempty(embedding)
    end

    @testset "multiple input token arrays" begin
        r = Langdock.create_openai_embeddings(ENV["LANGDOCK_API_KEY"], [[1, 2, 3, 4, 5], [42, 9001]])
        data = r.response["data"]
        @test length(data) == 2

        embedding1 = data[begin]["embedding"]
        @test typeof(embedding1) <: AbstractVector

        @test eltype(embedding1) == Float64
        @test !isempty(embedding1)

        embedding2 = data[end]["embedding"]
        @test typeof(embedding1) <: AbstractVector
        @test eltype(embedding1) == Float64
        @test !isempty(embedding1)
    end
end
