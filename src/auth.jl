# Constants 
# ---------
const DEFAULT_PROVIDER_CACHE = Ref{Union{LangdockProvider, Nothing}}(nothing) # Cache for the default provider


"""
    create_provider(; kwargs...)

Create a new LangdockProvider instance with configuration.

# Keyword Arguments
- `api_key::String=""`: API key for authentication (defaults to environment variable)
- `base_url::String="https://api.langdock.com"`: Base URL for the API
- `region::String="eu"`: Region for API endpoints ("eu" or "us"). It can also be set via environment variable `LANGDOCK_REGION`. Defaults to "eu".
- `timeout::Int=30`: Request timeout in seconds. Defaults to 30 seconds.

# Returns
- `LangdockProvider`: Configured provider instance

# Errors
- `ArgumentError`: If API key is empty
- `ArgumentError`: If region is not a available region. See `Langdock.REGIONS`.
- `ArgumentError`: If timeout is not positive.

# Example
```julia
# Using environment variable for API key
provider = create_provider(region="us", timeout=60)

# Using explicit API key
provider = create_provider(api_key="your-key-here", region="eu")
```
"""
function create_provider(;
    api_key::String="",
    api_version::String=DEFAULT_API_VERSION,
    base_url::String=DEFAULT_BASE_URL,
    region::String=DEFAULT_REGION,
    timeout::Int=DEFAULT_TIMEOUT
)::LangdockProvider
    
    # If no API key provided, try to get from environment
    if isempty(api_key)
        api_key = get_api_key()
        isempty(api_key) && throw(ArgumentError(
            "No API key provided. Set `LANGDOCK_API_KEY`` environment variable or pass api_key parameter."
        ))
    end

    # Get api version from environment if not provided
    if haskey(ENV, "LANGDOCK_API_VERSION")
        env_api_version = ENV["LANGDOCK_API_VERSION"]
        env_api_version in API_VERSIONS && (api_version = env_api_version)
    end
    
    # Get region from environment if not provided
    if haskey(ENV, "LANGDOCK_REGION")
        env_region = ENV["LANGDOCK_REGION"]
        env_region in REGIONS && (region = env_region)
    end
    
    # Get timeout from environment if not provided
    if haskey(ENV, "LANGDOCK_TIMEOUT")
        try
            env_timeout = parse(Int, ENV["LANGDOCK_TIMEOUT"])
            env_timeout > 0 && (timeout = env_timeout)
        catch
            # Ignore invalid timeout in environment
        end
    end
    
    # Get base URL from environment if not provided
    haskey(ENV, "LANGDOCK_BASE_URL") && (base_url = ENV["LANGDOCK_BASE_URL"])
    
    LangdockProvider(
        api_key=api_key,
        api_version=api_version,
        base_url=base_url,
        region=region,
        timeout=timeout
    )
end

"""
    get_api_key()

Retrieve the Langdock API key from environment variables.

Looks for the following environment variables in order:
1. LANGDOCK_API_KEY
2. LANGDOCK_KEY

# Returns
- `String`: The API key if found
- `""`: Empty string if no API key is found in environment

# Example
```julia
api_key = get_api_key()
if isempty(api_key)
    error("No API key found")
end
```
"""
function get_api_key()::String
    # Check primary environment variable
    haskey(ENV, "LANGDOCK_API_KEY") && return ENV["LANGDOCK_API_KEY"]
    
    # Check alternative environment variable
    haskey(ENV, "LANGDOCK_KEY") && return ENV["LANGDOCK_KEY"]
    
    return ""
end

"""
    get_default_provider()

Get or create a default provider instance using environment variables.

This function caches the provider instance for reuse across calls.
To reset the cache, set `DEFAULT_PROVIDER_CACHE[] = nothing`.

# Returns
- `LangdockProvider`: The default provider instance

# Errors
- `ArgumentError`: If no API key is found in environment variables

# Example
```julia
provider = get_default_provider()
# Use provider for API calls
```
"""
function get_default_provider()::LangdockProvider
    isnothing(DEFAULT_PROVIDER_CACHE[]) && (DEFAULT_PROVIDER_CACHE[] = create_provider())
    DEFAULT_PROVIDER_CACHE[]
end

"""
    reset_default_provider!()

Reset the default provider cache, forcing it to be recreated on next use.

# Example
```julia
reset_default_provider!()
# Next call to get_default_provider() will create a new instance
```
"""
function reset_default_provider!()
    DEFAULT_PROVIDER_CACHE[] = nothing
end
