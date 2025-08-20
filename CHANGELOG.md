# Changelog

All notable changes to Langdock.jl will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-01-20

### Added
- Initial release of Langdock.jl
- Core infrastructure for Langdock API integration
  - `LangdockProvider` type for managing API credentials and configuration
  - `langdock_request` function for authenticated API requests
  - `LangdockResponse` wrapper for API responses
  - Bearer token authentication support
  - Region-based routing (EU/US)
  
- Assistant API endpoints
  - `create_assistant_chat` - Create chat completions using assistants
  - `list_assistant_models` - List available models for Assistant API
  - Support for both existing assistants (via ID) and temporary assistant configurations
  - Attachment support for assistant conversations
  
- Embeddings API
  - `create_openai_embeddings` - Generate text embeddings using OpenAI models
  - Support for single and batch text inputs
  
- Type definitions
  - `AssistantConfig` for assistant configuration
  - `AbstractLangdockProvider` interface
  
- Environment variable configuration
  - `LANGDOCK_API_KEY` for API authentication
  - `LANGDOCK_REGION` for default region selection
  - `LANGDOCK_TIMEOUT` for request timeout configuration
  - `LANGDOCK_BASE_URL` for custom base URL
  
- Comprehensive test suite
- API endpoints documentation
- CI/CD pipeline setup

### Known Limitations
- Knowledge Folder API not implemented
- OpenAI chat completions endpoint not implemented
- Anthropic Messages API not implemented
- Mistral/Codestral completions not implemented