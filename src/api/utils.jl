"""
    build_url(provider::LangdockProvider, endpoint::String)

Build the complete URL for an API endpoint.

# Arguments
- `provider`: The LangdockProvider configuration
- `endpoint`: The API endpoint path

# Returns
- `String`: The complete URL

# Example
```julia
url = build_url(provider, "/openai/{region}/{api_version}/chat/completions")
# Returns: "https://api.langdock.com/openai/eu/v1/chat/completions"
```
"""
function build_url(provider::LangdockProvider, endpoint::String)::String
    # Remove leading slash if present
    endpoint = lstrip(endpoint, '/')
    
    # Handle region-specific endpoints
    if occursin("{region}", endpoint) 
        endpoint = replace(endpoint, "{region}" => provider.region)
    end

    if occursin("{api_version}", endpoint)
        endpoint = replace(endpoint, "{api_version}" => provider.api_version)
    end
     
    # Build complete URL
    base_url = rstrip(provider.base_url, '/')
    return "$base_url/$endpoint"
end

"""
    handle_response(response::HTTP.Response)

Process an HTTP response and handle errors.

# Arguments
- `response`: The HTTP response to process

# Returns
- `LangdockResponse`: Wrapped response with parsed data

# Errors
- `LangdockError`: If the response indicates an error (status >= 400)

# Example
```julia
response = HTTP.request(...)
result = handle_response(response)
```
"""
function handle_response(response::HTTP.Response)::LangdockResponse
    @debug "Response status: $(response.status)"
    
    # Check for error status codes
    response.status >= 400 && begin
        # Try to parse error message from response body
        error_data = try
            JSON3.read(response.body, Dict)
        catch
            Dict("message" => "Unknown error", "error" => String(response.body))
        end
        
        error_message = get(error_data, "message", get(error_data, "error", "Request failed"))
        
        @error "API request failed" status=response.status message=error_message
        
        throw(LangdockError(
            error_message,
            status_code=response.status,
            response=error_data
        ))
    end
    
    # Return wrapped response
    return LangdockResponse(response)
end

# Helper function to prepare common request headers
function prepare_headers(provider::LangdockProvider, additional_headers::Dict=Dict())::Dict{String, String}
    request_headers = Dict{String, String}(
        "Authorization" => "Bearer $(provider.api_key)",
        "Content-Type" => "application/json"
    )
    
    for (key, value) in additional_headers
        request_headers[string(key)] = string(value)
    end
    
    return request_headers
end

# Helper function to prepare common HTTP options
function prepare_http_options(provider::LangdockProvider)::Dict{Symbol, Any}
    return Dict{Symbol, Any}(
        :readtimeout => provider.timeout,
        :connecttimeout => min(provider.timeout, 10),
        :retry => false,
        :verbose => 0
    )
end