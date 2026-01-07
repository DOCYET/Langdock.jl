using Langdock
using Test
using HTTP
using JSON3

@testset "Assistant API" begin

    @testset "list_assistant_models" begin
        # Test with API key
        response = Langdock.list_assistant_models(ENV["LANGDOCK_API_KEY"])
        @test response isa Langdock.LangdockResponse
        @test response.status == 200
        @test haskey(response.response, :data)
        @test length(response.response[:data]) > 0

        # Test with provider
        provider = get_default_provider()
        response = Langdock.list_assistant_models(provider)
        @test response isa Langdock.LangdockResponse
        @test response.status == 200
        @test haskey(response.response, :data)
        @test length(response.response[:data]) > 0
    end

    @testset "create_assistant_chat" begin

            @testset "with existing assistant" begin 
            assistant_id = ENV["LANGDOCK_TEST_ASSISTANT_ID"]

            # Test with no API key
            @test_throws ArgumentError Langdock.create_assistant_chat(
                "",
                [
                    Dict("role" => "user", "content" => "Hello!")
                ],
                assistant_id = assistant_id
            )
            
            # Test with valid API key and messages
            response = Langdock.create_assistant_chat(
                ENV["LANGDOCK_API_KEY"],
                [
                    Dict("role" => "user", "content" => "Hello!")
                ],
                assistant_id = assistant_id
            )
            @test response isa Langdock.LangdockResponse
            @test haskey(response.response, "result")

            # Test with provider 
            provider = get_default_provider() 
            response = Langdock.create_assistant_chat(
                provider,
                [
                    Dict("role" => "user", "content" => "Hello!")
                ],
                assistant_id = assistant_id
            )
            println("Response: ", response)
            @test response.status == 200
            @test response.response["result"][begin]["role"] == "assistant"
            @test response.response["result"][begin]["content"] isa AbstractString
            @test response.response["result"][begin]["id"] isa AbstractString
        

            # Test with htttp kwargs 
            response = Langdock.create_assistant_chat(
                ENV["LANGDOCK_API_KEY"],
                [
                    Dict("role" => "user", "content" => "Hello!")
                ],
                assistant_id = assistant_id,
                http_kwargs = (connect_timeout = 10, readtimeout = 0)
            )
            println("Response: ", response)
            @test response.status == 200
            @test response.response["result"][begin]["role"] == "assistant"
            @test response.response["result"][begin]["content"] isa AbstractString
            @test response.response["result"][begin]["id"] isa AbstractString
        end
        
        @testset "creating a new assistant on the fly " begin 
            assistant_config = Langdock.AssistantConfig(
                "Test Assistant", # name
                "You are a helpful assistant", # instructions
                description = "This is a test assistant created on the fly.",
                model = "gpt-4o-mini",
                capabilities = Dict(
                    "webSearch" => true
                )
            )
            response = Langdock.create_assistant_chat(
                ENV["LANGDOCK_API_KEY"],
                [
                    Dict("role" => "user", "content" => "Hello!")
                ],
                assistant = assistant_config
            )

            println("Response: ", response)
            @test response.status == 200
            @test response.response["result"][begin]["role"] == "assistant"
            @test response.response["result"][begin]["content"] isa AbstractString
            @test response.response["result"][begin]["id"] isa AbstractString
        end
 
    end
end 


