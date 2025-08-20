@testset "Request Tests" begin
    
    # Create test provider
    test_provider = Langdock.LangdockProvider(
        api_key="test-api-key",
        api_version="v1",
        base_url="https://api.langdock.com",
        region="eu",
        timeout=30
    )
    
    @testset "build_url" begin
        # Test basic URL building
        url = Langdock.build_url(test_provider, "/test/endpoint")
        @test url == "https://api.langdock.com/test/endpoint"
        
        # Test with leading slash removal
        url = Langdock.build_url(test_provider, "test/endpoint")
        @test url == "https://api.langdock.com/test/endpoint"
        
        # Test with region placeholder
        url = Langdock.build_url(test_provider, "/openai/{region}/v1/chat/completions")
        @test url == "https://api.langdock.com/openai/eu/v1/chat/completions"
        
        # Test with api_version placeholder
        url = Langdock.build_url(test_provider, "/assistant/{api_version}/models")
        @test url == "https://api.langdock.com/assistant/v1/models"
        
        # Test with both region and api_version placeholders
        url = Langdock.build_url(test_provider, "/api/{region}/{api_version}/endpoint")
        @test url == "https://api.langdock.com/api/eu/v1/endpoint"
        
        # Test with US region
        us_provider = Langdock.LangdockProvider(
            api_key="test-key",
            region="us"
        )
        url = Langdock.build_url(us_provider, "/openai/{region}/{api_version}/embeddings")
        @test url == "https://api.langdock.com/openai/us/v1/embeddings"
        
        # Test with trailing slash in base URL
        provider_with_slash = Langdock.LangdockProvider(
            api_key="test-key",
            base_url="https://api.langdock.com/"
        )
        url = Langdock.build_url(provider_with_slash, "test")
        @test url == "https://api.langdock.com/test"
        
        # Test with no placeholders
        url = Langdock.build_url(test_provider, "/simple/path")
        @test url == "https://api.langdock.com/simple/path"
        
        # Test with multiple slashes
        url = Langdock.build_url(test_provider, "///test///endpoint///")
        @test url == "https://api.langdock.com/test///endpoint///"
    end
    
end