@testset "Types Module Tests" begin
    
    @testset "LangdockProvider" begin
        # Test valid provider creation with all fields
        @test_nowarn provider = Langdock.LangdockProvider(
            api_key="test-api-key-123",
            api_version="v1",
            base_url="https://api.langdock.com",
            region="eu",
            timeout=30
        )
        
        provider = Langdock.LangdockProvider(
            api_key="test-api-key-123",
            api_version="v1",
            region="us"
        )
        @test provider.api_key == "test-api-key-123"
        @test provider.api_version == "v1"
        @test provider.region == "us"
        @test provider.timeout == 30
        
        # Test default values
        provider = Langdock.LangdockProvider(api_key="test-key")
        @test provider.api_key == "test-key"
        @test provider.api_version == Langdock.DEFAULT_API_VERSION
        @test provider.base_url == Langdock.DEFAULT_BASE_URL
        @test provider.region == Langdock.DEFAULT_REGION
        @test provider.timeout == Langdock.DEFAULT_TIMEOUT
        
        # Test invalid API key
        @test_throws ArgumentError Langdock.LangdockProvider(api_key="")
        
        # Test invalid API version
        @test_throws ArgumentError Langdock.LangdockProvider(
            api_key="test-key",
            api_version="v99"
        )
        
        # Test invalid region
        @test_throws ArgumentError Langdock.LangdockProvider(
            api_key="test-key",
            region="invalid"
        )
        
        # Test invalid timeout
        @test_throws ArgumentError Langdock.LangdockProvider(
            api_key="test-key",
            timeout=0
        )
        @test_throws ArgumentError Langdock.LangdockProvider(
            api_key="test-key",
            timeout=-1
        )
    end
    
    @testset "Message" begin
        # Test simple message creation
        msg = Langdock.Message("user", "Hello")
        @test msg.role == "user"
        @test msg.content == "Hello"
        
        # Test message with different roles
        msg = Langdock.Message("assistant", "Response")
        @test msg.role == "assistant"
        @test msg.content == "Response"
        
        msg = Langdock.Message("system", "System prompt")
        @test msg.role == "system"
        @test msg.content == "System prompt"
        
        msg = Langdock.Message("tool", "Tool response")
        @test msg.role == "tool"
        @test msg.content == "Tool response"
        
        # Test multimodal content
        content = ["text", Dict("type" => "image")]
        msg = Langdock.Message("user", content)
        @test msg.content == content
        
        # Test invalid role
        @test_throws ArgumentError Langdock.Message("invalid", "content")
        
        # Test valid roles
        for role in ["user", "assistant", "system", "tool"]
            @test_nowarn Langdock.Message(role, "content")
        end
        
        # Test to_dict conversion
        msg = Langdock.Message("user", "Hello")
        dict = Langdock.to_dict(msg)
        @test dict["role"] == "user"
        @test dict["content"] == "Hello"
        @test length(dict) == 2
    end
    
    @testset "AssistantMessage" begin
        # Test simple assistant message creation
        msg = Langdock.AssistantMessage("user", "Hello")
        @test msg.role == "user"
        @test msg.content == "Hello"
        @test isnothing(msg.attachmentIds)
        
        # Test with attachmentIds
        msg = Langdock.AssistantMessage(
            "user",
            "Hello",
            attachmentIds=["file1", "file2"]
        )
        @test msg.role == "user"
        @test msg.content == "Hello"
        @test msg.attachmentIds == ["file1", "file2"]
        @test length(msg.attachmentIds) == 2
        
        # Test multimodal content with attachments
        content = ["text", Dict("type" => "image")]
        msg = Langdock.AssistantMessage(
            "assistant",
            content,
            attachmentIds=["doc1"]
        )
        @test msg.content == content
        @test msg.attachmentIds == ["doc1"]
        
        # Test invalid role
        @test_throws ArgumentError Langdock.AssistantMessage("invalid", "content")
        
        # Test to_dict conversion without attachments
        msg = Langdock.AssistantMessage("user", "Hello")
        dict = Langdock.to_dict(msg)
        @test dict["role"] == "user"
        @test dict["content"] == "Hello"
        @test !haskey(dict, "attachmentIds")
        @test length(dict) == 2
        
        # Test to_dict conversion with attachments
        msg = Langdock.AssistantMessage(
            "user",
            "Hello",
            attachmentIds=["file1", "file2"]
        )
        dict = Langdock.to_dict(msg)
        @test dict["role"] == "user"
        @test dict["content"] == "Hello"
        @test dict["attachmentIds"] == ["file1", "file2"]
        @test length(dict) == 3
    end
    
    @testset "LangdockResponse" begin
        # Create mock HTTP response
        mock_body = JSON3.write(Dict("result" => "success", "data" => [1, 2, 3]))
        mock_response = HTTP.Response(200, ["Content-Type" => "application/json"], mock_body)
        
        # Test response creation
        response = Langdock.LangdockResponse(mock_response)
        @test response.response === mock_response
        @test !isnothing(response.data)
        @test response.data["result"] == "success"
        @test response.data["data"] == [1, 2, 3]
        
        # Test with invalid JSON
        invalid_response = HTTP.Response(200, [], "not json")
        response = Langdock.LangdockResponse(invalid_response)
        @test response.response === invalid_response
        @test isnothing(response.data)
    end
    
    @testset "LangdockError" begin
        # Test basic error
        err = Langdock.LangdockError("Test error")
        @test err.message == "Test error"
        @test isnothing(err.status_code)
        @test isnothing(err.response)
        
        # Test error with status code
        err = Langdock.LangdockError("API error", status_code=400)
        @test err.message == "API error"
        @test err.status_code == 400
        
        # Test error with response
        response_data = Dict("error" => "Invalid request")
        err = Langdock.LangdockError("Request failed", status_code=400, response=response_data)
        @test err.message == "Request failed"
        @test err.status_code == 400
        @test err.response == response_data
        
        # Test error display
        io = IOBuffer()
        show(io, err)
        output = String(take!(io))
        @test occursin("LangdockError", output)
        @test occursin("Request failed", output)
        @test occursin("400", output)
    end
end