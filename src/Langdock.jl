module Langdock

# Base dependencies
# ----------------
using HTTP
using JSON3
using Logging
using StructTypes 

# Constansts
# -----------
const VERSION = v"0.1.0"


# File inclusions 
# ----------------
include("constants.jl")
export REGIONS 

# Types 
include("types/assistant_config.jl")
export AssistantConfig

include("types/provider.jl")
export AbstractLangdockProvider, LangdockProvider, get_api_key, get_default_provider, reset_default_provider!

include("types/response.jl")
export LangdockResponse

# API 
include("api/request.jl")
export build_url, auth_header, langdock_request

include("api/assistants.jl")
export list_assistant_models, create_assistant_chat

include("api/embeddings.jl")
export create_openai_embeddings



"""
    Langdock

Julia client library for the Langdock API.

This package provides a comprehensive interface to interact with Langdock's API endpoints,
including support for:
- OpenAI-compatible chat completions
- Anthropic Claude messages
- Mistral completions
- Text embeddings
- Assistant API
- Knowledge folder management
- File attachments

# Quick Start

```julia
using Langdock

# Set your API key as an environment variable
ENV["LANGDOCK_API_KEY"] = "your-api-key"

# Create a provider
provider = create_provider(region="eu")

# Make API calls
response = langdock_request(
    provider,
    "POST",
    "/openai/v1/chat/completions",
    body=Dict(
        "model" => "gpt-4o-mini",
        "messages" => [
            Dict("role" => "user", "content" => "Hello!")
        ]
    )
)
```

# Environment Variables

The package supports the following environment variables:
- `LANGDOCK_API_KEY`: Your Langdock API key
- `LANGDOCK_REGION`: Default region ("eu" or "us")
- `LANGDOCK_TIMEOUT`: Request timeout in seconds
- `LANGDOCK_BASE_URL`: Base URL for the API

# Modules

- `Types`: Type definitions for API objects
- `Auth`: Authentication and provider management
- `Core`: Core request functionality

# Key Types

- `LangdockProvider`: Configuration for API connections
- `LangdockResponse`: Wrapper for API responses
- `Message`: Chat message representation
- `LangdockError`: Custom error type

For more information, see the documentation at https://github.com/yourusername/Langdock.jl
"""
Langdock

# Utility function to check if package is properly configured
"""
    check_setup()

Check if the Langdock package is properly configured.

# Returns
- `true` if setup is valid
- `false` if there are configuration issues

# Example
```julia
if Langdock.check_setup()
    println("Langdock is ready to use!")
else
    println("Please configure your API key")
end
```
"""
function check_setup()::Bool
    api_key = get_api_key()
    
    if isempty(api_key)
        @warn "No API key found. Set LANGDOCK_API_KEY environment variable."
        return false
    end
    
    return true
end

# Display package info when loaded
function __init__()
    if get(ENV, "LANGDOCK_DEBUG", "false") == "true"
        @info "Langdock.jl v$VERSION loaded"
        
        if !check_setup()
            @info "Run `ENV[\"LANGDOCK_API_KEY\"] = \"your-key\"` to configure"
        end
    end
end

end # module Langdock
