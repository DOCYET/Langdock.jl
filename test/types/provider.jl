@testset "Provider tests" begin

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
    
    # Save original environment
    original_env = Dict{String, String}()
    for key in ["LANGDOCK_API_KEY", "LANGDOCK_KEY", "LANGDOCK_REGION", "LANGDOCK_TIMEOUT", "LANGDOCK_BASE_URL"]
        if haskey(ENV, key)
            original_env[key] = ENV[key]
            delete!(ENV, key)
        end
    end
    
    @testset "get_api_key" begin
        # Test with no environment variables
        @test Langdock.get_api_key() == ""
        
        # Test with LANGDOCK_API_KEY
        ENV["LANGDOCK_API_KEY"] = "test-key-primary"
        @test Langdock.get_api_key() == "test-key-primary"
        delete!(ENV, "LANGDOCK_API_KEY")
        
        # Test with LANGDOCK_KEY
        ENV["LANGDOCK_KEY"] = "test-key-secondary"
        @test Langdock.get_api_key() == "test-key-secondary"
        
        # Test priority (LANGDOCK_API_KEY over LANGDOCK_KEY)
        ENV["LANGDOCK_API_KEY"] = "primary"
        ENV["LANGDOCK_KEY"] = "secondary"
        @test Langdock.get_api_key() == "primary"
        
        # Cleanup
        delete!(ENV, "LANGDOCK_API_KEY")
        delete!(ENV, "LANGDOCK_KEY")
    end
    
    @testset "create_provider" begin
        # Test with explicit API key
        provider = Langdock.create_provider(api_key="test-api-key-123")
        @test provider.api_key == "test-api-key-123"
        @test provider.region == "eu"
        @test provider.timeout == 30
        @test provider.base_url == "https://api.langdock.com"
        
        # Test with custom parameters
        provider = Langdock.create_provider(
            api_key="test-key",
            region="us",
            timeout=60,
            base_url="https://custom.api.com"
        )
        @test provider.api_key == "test-key"
        @test provider.region == "us"
        @test provider.timeout == 60
        @test provider.base_url == "https://custom.api.com"
        
        # Test with environment variable
        ENV["LANGDOCK_API_KEY"] = "env-api-key"
        provider = Langdock.create_provider()
        @test provider.api_key == "env-api-key"
        delete!(ENV, "LANGDOCK_API_KEY")
        
        # Test environment overrides
        ENV["LANGDOCK_API_KEY"] = "env-key"
        ENV["LANGDOCK_REGION"] = "us"
        ENV["LANGDOCK_TIMEOUT"] = "45"
        ENV["LANGDOCK_BASE_URL"] = "https://env.api.com"
        
        provider = Langdock.create_provider()
        @test provider.api_key == "env-key"
        @test provider.region == "us"
        @test provider.timeout == 45
        @test provider.base_url == "https://env.api.com"
        
        # Test invalid environment timeout (should be ignored)
        ENV["LANGDOCK_TIMEOUT"] = "invalid"
        provider = Langdock.create_provider()
        @test provider.timeout == 30  # Should use default
        
        # Test invalid environment region (should be ignored)
        ENV["LANGDOCK_REGION"] = "invalid"
        provider = Langdock.create_provider()
        @test provider.region == "eu"  # Should use default
        
        # Cleanup
        for key in ["LANGDOCK_API_KEY", "LANGDOCK_REGION", "LANGDOCK_TIMEOUT", "LANGDOCK_BASE_URL"]
            delete!(ENV, key)
        end
        
        # Test errors
        @test_throws ArgumentError Langdock.create_provider(api_key="")
        @test_throws ArgumentError Langdock.create_provider()  # No env key
    end
    
    @testset "get_default_provider" begin
        # Reset cache first
        Langdock.reset_default_provider!()
        
        # Test without API key
        @test_throws ArgumentError Langdock.get_default_provider()
        
        # Test with API key
        ENV["LANGDOCK_API_KEY"] = "default-key-123"
        provider1 = Langdock.get_default_provider()
        @test provider1.api_key == "default-key-123"
        
        # Test caching - should return same instance
        provider2 = Langdock.get_default_provider()
        @test provider1 === provider2
        
        # Test reset
        Langdock.reset_default_provider!()
        provider3 = Langdock.get_default_provider()
        @test provider3 !== provider1  # Should be different instance
        @test provider3.api_key == "default-key-123"  # But same key
        
        # Cleanup
        delete!(ENV, "LANGDOCK_API_KEY")
        Langdock.reset_default_provider!()
    end
    
    # Restore original environment
    for (key, value) in original_env
        ENV[key] = value
    end
end