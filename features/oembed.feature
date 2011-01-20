Feature: OEmbed

    As an embedly user
    I want to call the the embedly api
    Because I want and oembed for a specific url

    Scenario Outline: Get the provider_url
        Given an embedly endpoint
        When oembed is called with the <url> URL
        Then the provider_url should be <provider_url>

        Examples:
            | url                                                          | provider_url            |
            | http://www.scribd.com/doc/13994900/Easter                    | http://www.scribd.com/  |
            | http://www.scribd.com/doc/28452730/Easter-Cards              | http://www.scribd.com/  |
            | http://www.youtube.com/watch?v=Zk7dDekYej0                   | http://www.youtube.com/ |
            | http://tweetphoto.com/14784358                               | http://plixi.com        |


    Scenario Outline: Get the provider_url with force flag
        Given an embedly endpoint
        When oembed is called with the <url> URL and force flag
        Then the provider_url should be <provider_url>

        Examples:
            | url                                                          | provider_url            |
            | http://www.youtube.com/watch?v=Zk7dDekYej0                   | http://www.youtube.com/ |


    Scenario Outline: Get multiple provider_urls
        Given an embedly endpoint
        When oembed is called with the <urls> URLs
        Then provider_url should be <provider_urls>

        Examples:
            | urls                                                                                      | provider_urls                                 |
            | http://www.scribd.com/doc/13994900/Easter,http://www.scribd.com/doc/28452730/Easter-Cards | http://www.scribd.com/,http://www.scribd.com/ |
            | http://www.youtube.com/watch?v=Zk7dDekYej0,http://plixi.com/p/16044847                    | http://www.youtube.com/,http://plixi.com      |


    Scenario Outline: Get the provider_url with pro
        Given an embedly endpoint with 3ea4fc74fd6d11df84894040444cdc60 key
        When oembed is called with the <url> URL
        Then the provider_url should be <provider_url>

        Examples:
            | url                                      | provider_url         |
            | http://blog.embed.ly/bob                 | http://posterous.com |
            | http://blog.doki-pen.org/cassandra-rules | http://posterous.com |


    Scenario Outline: Attempt to get 404 URL
        Given an embedly endpoint
        When oembed is called with the <url> URLs
        Then type should be error
        And error_code should be 404

        Examples:
            | url                                                              |
            | http://www.youtube.com/this/is/a/bad/url                         |
        
