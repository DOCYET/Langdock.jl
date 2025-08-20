using Langdock: AssistantConfig, get_default_provider 
using Test
using JSON3
@testset "AssistantConfig" begin 
    @testset "Basic construction" begin
        config = AssistantConfig("Test Assistant", "You are a helpful assistant")
        @test config.name == "Test Assistant"
        @test config.instructions == "You are a helpful assistant"
        @test isnothing(config.description)
        @test isnothing(config.temperature)
        @test isnothing(config.model)
        @test isnothing(config.capabilities)
        @test isnothing(config.actions)
        @test isnothing(config.vector_db)
        @test isnothing(config.knowledge_folder_ids)
        @test isnothing(config.attachment_ids)
    end

    @testset "Construction with optional fields" begin
        config = AssistantConfig(
            "Test Assistant",
            "Instructions";
            description="A test assistant",
            temperature=0.7,
            model="gpt-4",
            capabilities=Dict("web_search" => true),
            actions=Dict("api" => "endpoint"),
            vector_db=Dict("type" => "pinecone"),
            knowledge_folder_ids=["folder1", "folder2"],
            attachment_ids=["att1", "att2"]
        )
        
        @test config.description == "A test assistant"
        @test config.temperature == 0.7
        @test config.model == "gpt-4"
        @test config.capabilities["web_search"] == true
        @test config.actions["api"] == "endpoint"
        @test config.vector_db["type"] == "pinecone"
        @test config.knowledge_folder_ids == ["folder1", "folder2"]
        @test config.attachment_ids == ["att1", "att2"]
    end

    @testset "Validation" begin
        # Name too long
        @test_throws ArgumentError AssistantConfig("a"^65, "instructions")
        
        # Instructions too long
        @test_throws ArgumentError AssistantConfig("name", "a"^16385)
        
        # Description too long
        @test_throws ArgumentError AssistantConfig("name", "instructions"; description="a"^257)
        
        # Temperature out of range
        @test_throws ArgumentError AssistantConfig("name", "instructions"; temperature=-0.1)
        @test_throws ArgumentError AssistantConfig("name", "instructions"; temperature=1.1)
        
        # Valid edge cases
        @test AssistantConfig("a"^64, "instructions").name == "a"^64
        @test AssistantConfig("name", "a"^16384).instructions == "a"^16384
        @test AssistantConfig("name", "instructions"; description="a"^256).description == "a"^256
        @test AssistantConfig("name", "instructions"; temperature=0.0).temperature == 0.0
        @test AssistantConfig("name", "instructions"; temperature=1.0).temperature == 1.0
    end

    @testset "JSON3 serialization" begin
        config = AssistantConfig(
            "Test Assistant",
            "Instructions";
            description="Description",
            temperature=0.5,
            model="gpt-4",
            capabilities=Dict("search" => true),
            vector_db=Dict("enabled" => true),
            knowledge_folder_ids=["id1"],
            attachment_ids=["att1"]
        )
        
        json_str = JSON3.write(config)
        json_obj = JSON3.read(json_str)
        
        # Check field names are correctly mapped
        @test json_obj["name"] == "Test Assistant"
        @test json_obj["instructions"] == "Instructions"
        @test json_obj["description"] == "Description"
        @test json_obj["temperature"] == 0.5
        @test json_obj["model"] == "gpt-4"
        @test json_obj["capabilities"]["search"] == true
        @test json_obj["vectorDb"]["enabled"] == true  # Note camelCase
        @test json_obj["knowledgeFolderIds"] == ["id1"]  # Note camelCase
        @test json_obj["attachmentIds"] == ["att1"]  # Note camelCase
    end

    @testset "JSON3 serialization with nulls" begin
        config = AssistantConfig("Name", "Instructions", temperature=0.5)
        json_str = JSON3.write(config)
        json_obj = JSON3.read(json_str)
        
        @test length(json_obj) == 3  # Only name and instructions should be present
        @test json_obj["name"] == "Name"
        @test json_obj["instructions"] == "Instructions"
        @test json_obj["temperature"] == 0.5
    end

    @testset "JSON deserialization" begin 
        config = AssistantConfig(     
            "Test Assistant",
            "Instructions";
            description="Description",
            temperature=0.5,
            model="gpt-4",
            capabilities=Dict("search" => true),
            vector_db=Dict("enabled" => true),
            knowledge_folder_ids=["id1"],
            attachment_ids=["att1"]
        )
        
        json_str = JSON3.write(config)
        json_obj = JSON3.read(json_str, AssistantConfig)

        @test json_obj.name == "Test Assistant"
        @test json_obj.instructions == "Instructions"
        @test json_obj.description == "Description"
        @test json_obj.temperature == 0.5
        @test json_obj.model == "gpt-4"
        @test json_obj.capabilities["search"] == true
        @test json_obj.vector_db["enabled"] == true  
        @test json_obj.knowledge_folder_ids == ["id1"]  
        @test json_obj.attachment_ids == ["att1"]  
    end

end