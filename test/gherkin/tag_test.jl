using Test
using ExecutableSpecifications.Gherkin: hastag, parsefeature, issuccessful, istagsline

@testset "Tags                 " begin
    @testset "Feature tags" begin
        @testset "@tag1 is applied to a feature; The parsed feature has @tag1" begin
            text = """
            @tag1
            Feature: Some description
            """

            result = parsefeature(text)

            @test issuccessful(result)
            feature = result.value
            @test hastag(feature, "@tag1")
        end

        @testset "Feature without tags; The parsed feature does not have @tag1" begin
            text = """
            Feature: Some description
            """

            result = parsefeature(text)

            @test issuccessful(result)
            @test hastag(result.value, "@tag1") == false
        end

        @testset "Feature with multiple tags; The parsed feature has all tags" begin
            text = """
            @tag1 @tag2 @tag3
            Feature: Some description
            """

            result = parsefeature(text)

            @test issuccessful(result)
            @test hastag(result.value, "@tag1")
            @test hastag(result.value, "@tag2")
            @test hastag(result.value, "@tag3")
        end
    end

    @testset "Scenario tags" begin
        @testset "Scenario has one tag; The parsed scenario has tag1" begin
            text = """
            Feature: Some description

                @tag1
                Scenario: Some description
                    Given a precondition
            """

            result = parsefeature(text)

            @test issuccessful(result)
            feature = result.value
            @test hastag(feature.scenarios[1], "@tag1")
        end

        @testset "Scenario has no tags; The parsed scenario does not have tag1" begin
            text = """
            Feature: Some description

                Scenario: Some description
                    Given a precondition
            """

            result = parsefeature(text)

            @test issuccessful(result)
            @test hastag(result.value.scenarios[1], "@tag1") == false
        end

        @testset "Feature has tag1, but no the scenario; The parsed scenario does not have tag1" begin
            text = """
            @tag1
            Feature: Some description

                Scenario: Some description
                    Given a precondition
            """

            result = parsefeature(text)

            @test issuccessful(result)
            @test hastag(result.value.scenarios[1], "@tag1") == false
        end

        @testset "Second Scenario has one tag; The second scenario has tag1" begin
            text = """
            Feature: Some description

                Scenario: The first scenario with no tags
                    Given a precondition

                @tag1
                Scenario: Some description
                    Given a precondition
            """

            result = parsefeature(text)

            @test issuccessful(result)
            feature = result.value
            @test hastag(feature.scenarios[2], "@tag1")
        end
    end

    @testset "Robustness" begin
        @testset "Tag @tag1-2 contains a hyphen; Tag is read as @tag1-2" begin
            text = """
            @tag1-2
            Feature: Some description
            """

            result = parsefeature(text)

            @test issuccessful(result)
            feature = result.value
            @test hastag(feature, "@tag1-2")
        end

        @testset "Feature has a list of tags in its free text header, and no scenarios; The tags are in the free text header" begin
            text = """
            Feature: Some description
                @tag1
                @tag2
            """

            result = parsefeature(text)

            @test issuccessful(result)
            feature = result.value
            @test "@tag1" in feature.header.long_description
            @test "@tag2" in feature.header.long_description
        end
    end

    @testset "Is tags" begin
        @testset "One tag; Yes" begin
            @test istagsline("@tag")
        end        
    end
end