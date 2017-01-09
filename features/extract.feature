Feature: Extract

    As an embedly user
    I want to call the the embedly api
    Because I want to extract a url

    Scenario Outline: Get the meta description with pro
        Given an embedly api with key
        When extract is called with the <url> URL
        Then the description should start with <metadesc>
        And objectify api_version is 2

        Examples:
            | url                                         | metadesc                    |
            | https://www.youtube.com/watch?v=jNQXAC9IVRw | The first video on YouTube. |
