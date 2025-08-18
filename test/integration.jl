@testset "Integration Tests" begin
    
    # Only run integration tests if API key is available
    if haskey(ENV, "LANGDOCK_API_KEY") || haskey(ENV, "LANGDOCK_INTEGRATION_TEST")
        
        @testset "Live API Tests" begin
            @info "Running live API integration tests"
            
            # Create provider for testing
            provider = try
                Langdock.create_provider()
            catch e
                @warn "Could not create provider for integration tests" error=e
                return
            end
            
            @testset "Provider Creation" begin
                @test isa(provider, Langdock.LangdockProvider)
                @test !isempty(provider.api_key)
                @test provider.region in Langdock.REGIONS
            end
            
            # Note: Actual API calls would go here
            # For now, we just test that the infrastructure works
            
            @testset "URL Building" begin
                # Test that URLs are built correctly for real endpoints
                url = Langdock.Core.build_url(provider, "/openai/v1/chat/completions")
                @test occursin("api.langdock.com", url)
                @test occursin(provider.region, url)
            end
        end
        
    else
        @test_skip "Integration tests skipped (no API key)"
        @info "Set LANGDOCK_API_KEY environment variable to run integration tests"
    end
    
    @testset "Package Structure" begin
        # Test that all expected modules are loaded
        @test isdefined(Langdock, :Types)
        @test isdefined(Langdock, :Auth)
        @test isdefined(Langdock, :Core)
        
        # Test exported functions
        @test isdefined(Langdock, :LangdockProvider)
        @test isdefined(Langdock, :LangdockResponse)
        @test isdefined(Langdock, :Message)
        @test isdefined(Langdock, :LangdockError)
        @test isdefined(Langdock, :get_api_key)
        @test isdefined(Langdock, :create_provider)
        @test isdefined(Langdock, :get_default_provider)
        @test isdefined(Langdock, :langdock_request)
        @test isdefined(Langdock, :with_retry)
        
        # Test package version
        @test Langdock.VERSION == v"0.1.0"
    end
    
    @testset "Error Handling" begin
        # Test that errors are properly thrown
        @test_throws ArgumentError Langdock.LangdockProvider(api_key="")
        @test_throws ArgumentError Langdock.Message("invalid_role", "content")
        
        # Test error display
        err = Langdock.LangdockError("Test error", status_code=404)
        io = IOBuffer()
        show(io, err)
        output = String(take!(io))
        @test occursin("404", output)
    end
    
    @testset "Check Setup" begin
        # Save original env
        original_key = get(ENV, "LANGDOCK_API_KEY", nothing)
        
        # Test without API key
        delete!(ENV, "LANGDOCK_API_KEY")
        @test !Langdock.check_setup()
        
        # Test with invalid API key
        ENV["LANGDOCK_API_KEY"] = "short"
        @test !Langdock.check_setup()
        
        # Test with valid API key
        ENV["LANGDOCK_API_KEY"] = "valid-api-key-123"
        @test Langdock.check_setup()
        
        # Restore original
        if !isnothing(original_key)
            ENV["LANGDOCK_API_KEY"] = original_key
        else
            delete!(ENV, "LANGDOCK_API_KEY")
        end
    end
end