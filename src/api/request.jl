"""
    simple_request(provider, endpoint, body; headers=Dict())

Make a simple HTTP POST request to the Langdock API.

# Arguments
- `provider::LangdockProvider`: Provider configuration
- `endpoint::String`: API endpoint path with {region} placeholder
- `body::Dict`: Request body

# Keyword Arguments  
- `headers::Dict=Dict()`: Additional headers

# Returns
- `LangdockResponse`: The API response
"""
function simple_request(
    provider::LangdockProvider,
    endpoint::String,
    body::Dict;
    headers::Dict=Dict()
)::LangdockResponse
    
    url = build_url(provider, endpoint)
    
    @debug "Making simple request" url=url
    
    request_headers = prepare_headers(provider, headers)
    http_kwargs = prepare_http_options(provider)
    
    json_body = JSON3.write(body)
    @debug "Request body" body=json_body
    
    response = HTTP.request(
        "POST",
        url,
        request_headers,
        json_body;
        http_kwargs...
    )
    
    return handle_response(response)
end

"""
    streaming_request(provider, endpoint, body, stream_callback; headers=Dict())

Make a streaming HTTP POST request to the Langdock API.

# Arguments
- `provider::LangdockProvider`: Provider configuration
- `endpoint::String`: API endpoint path with {region} placeholder
- `body::Dict`: Request body
- `stream_callback::Function`: Callback function for processing streaming chunks

# Keyword Arguments
- `headers::Dict=Dict()`: Additional headers

# Returns
- `LangdockResponse`: The API response
"""
function streaming_request(
    provider::LangdockProvider,
    endpoint::String,
    body::Dict,
    stream_callback::Function;
    headers::Dict=Dict()
)::LangdockResponse
    
    url = build_url(provider, endpoint)
    
    @debug "Making streaming request" url=url
    
    request_headers = prepare_headers(provider, headers)
    http_kwargs = prepare_http_options(provider)
    
    json_body = JSON3.write(body)
    @debug "Request body" body=json_body
    
    buffer = IOBuffer()
    
    response = HTTP.request(
        "POST",
        url,
        request_headers,
        json_body;
        response_stream=buffer,
        http_kwargs...
    ) do http
        for line in eachline(http)
            !isempty(line) && startswith(line, "data: ") && begin
                data_str = line[7:end]  # Remove "data: " prefix
                
                data_str == "[DONE]" && begin
                    @debug "Stream complete"
                    break
                end
                
                try
                    chunk = JSON3.read(data_str, Dict)
                    stream_callback(chunk)
                catch e
                    @warn "Failed to parse streaming chunk" error=e chunk=data_str
                end
            end
        end
    end
    
    # Create response with accumulated data
    response = HTTP.Response(
        response.status,
        response.headers,
        take!(buffer)
    )
    
    return handle_response(response)
end


"""
    with_retry(f::Function; max_attempts::Int=3, delay::Float64=1.0)

Execute a function with exponential backoff retry logic.

# Arguments
- `f`: Function to execute
- `max_attempts`: Maximum number of attempts (default: 3)
- `delay`: Initial delay in seconds (default: 1.0)

# Returns
- Result of the function call

# Example
```julia
response = with_retry() do
    langdock_request(provider, "POST", endpoint, body=data)
end
```
"""
function with_retry(f::Function; max_attempts::Int=3, delay::Float64=1.0)
    last_error = nothing
    
    for attempt in 1:max_attempts
        try
            return f()
        catch e
            last_error = e
            
            # Don't retry on client errors (4xx)
            if isa(e, LangdockError) && !isnothing(e.status_code) && 400 <= e.status_code < 500
                throw(e)
            end
            
            if attempt < max_attempts
                sleep_time = delay * (2.0 ^ (attempt - 1))
                @warn "Request failed, retrying..." attempt=attempt max_attempts=max_attempts sleep=sleep_time error=e
                sleep(sleep_time)
            end
        end
    end
    
    @error "All retry attempts failed" max_attempts=max_attempts
    throw(last_error)
end
