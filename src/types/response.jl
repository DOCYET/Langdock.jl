"""
    LangdockResponse

Wrapper for API responses from Langdock endpoints.

# Fields
- `status`: HTTP status code of the response
- `response`: The raw HTTP.Response object
"""
struct LangdockResponse{R}
    status::Int16
    response::R
end