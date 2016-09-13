Feature: OEmbed

    As an embedly user
    I want to call the the embedly api
    Because I want and oembed for a specific url

    Scenario Outline: Get the provider_url
        Given an embedly api with key
        When oembed is called with the <url> URL
        Then the provider_url should be <provider_url>

        Examples:
            | url                                         | provider_url             |
            | https://www.youtube.com/watch?v=Zk7dDekYej0 | https://www.youtube.com/ |
            | https://placekitten.com/200/300             | https://placekitten.com  |


    Scenario Outline: Get the types
        Given an embedly api with key
        When oembed is called with the <url> URL
        Then the type should be <type>

        Examples:
            | url                                         | type  |
            | https://github.com/embedly/embedly-ruby     | link  |
            | http://www.youtube.com/watch?v=Zk7dDekYej0  | video |
            | https://placekitten.com/200/300             | photo |


    Scenario Outline: Get the provider_url with force flag
        Given an embedly api with key
        When oembed is called with the <url> URL and force flag
        Then the provider_url should be <provider_url>

        Examples:
            | url                                         | provider_url             |
            | https://www.youtube.com/watch?v=Zk7dDekYej0 | https://www.youtube.com/ |


    Scenario Outline: Get multiple provider_urls
        Given an embedly api with key
        When oembed is called with the <urls> URLs
        Then provider_url should be <provider_urls>

        Examples:
            | urls                                                                                    | provider_urls                                     |
            | https://www.youtube.com/watch?v=jNQXAC9IVRw,https://www.youtube.com/watch?v=dQw4w9WgXcQ | https://www.youtube.com/,https://www.youtube.com/ |
            | https://www.youtube.com/watch?v=Zk7dDekYej0,https://placekitten.com/200/300             | https://www.youtube.com/,https://placekitten.com  |


    Scenario Outline: Attempt to get 404 URL
        Given an embedly api with key
        When oembed is called with the <url> URL
        Then type should be error
        And error_code should be 404
        And type should be error

        Examples:
            | url                                       |
            | http://www.youtube.com/watch/is/a/bad/url |
            | https://fav.me/alsfsdf                    |


    Scenario Outline: Attempt multi get 404 URLs
        Given an embedly api with key
        When oembed is called with the <urls> URLs
        Then error_code should be <errcode>
        And type should be <types>

        Examples:
            | urls                                                                              | errcode | types       |
            | https://www.youtube.com/watch/a/bassd/url,http://www.youtube.com/watch/ldf/asdlfj | 404,404 | error,error |
            | https://www.youtube.com/watch/zzzzasdf/kl,http://placekitten.com/g/200/300        | 404,    | error,photo |
            | https://placekitten.com/200/300,https://www.youtube.com/watch/asdfasdf/asdf       | ,404    | photo,error |

    Scenario Outline: Attempt to get 414 URL
        Given an embedly api with key
        When oembed is called with the <url> URL
        Then type should be error
        And error_code should be 414
        And type should be error

        Examples:
            | url |
            | http://www.youtube.com/watch/is/a/bad/url/because/it/is/longer/than/2048/characters/this/is/much/too/long/for/a/url/and/shouldnt/even/be/sent/to/the/server/aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa|
