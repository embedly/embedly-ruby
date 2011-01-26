Feature: Objectify

    As an embedly user
    I want to call the the embedly api
    Because I want to objectify a url

    Scenario Outline: Get the meta description
        Given an embedly endpoint
        When objectify is called with the <url> URL
        Then the meta.description should start with <metadesc>

        Examples:
            | url                            | metadesc                 |
            | http://tweetphoto.com/14784358 | Plixi allows user to ins |
