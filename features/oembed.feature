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


    Scenario Outline: Get the types
        Given an embedly endpoint
        When oembed is called with the <url> URL
        Then the type should be <type>

        Examples:
            | url                                                          | type  |
            | http://www.scribd.com/doc/13994900/Easter                    | rich  |
            | http://www.scribd.com/doc/28452730/Easter-Cards              | rich  |
            | http://www.youtube.com/watch?v=Zk7dDekYej0                   | video |
            | http://tweetphoto.com/14784358                               | photo |


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
        Given an embedly endpoint with key
        When oembed is called with the <url> URL
        Then the provider_url should be <provider_url>

        Examples:
            | url                                                                              | provider_url               |
            | http://blog.embed.ly/bob                                                         | http://posterous.com       |
            | http://blog.doki-pen.org/cassandra-rules                                         | http://posterous.com       |
            | http://www.guardian.co.uk/media/2011/jan/21/andy-coulson-phone-hacking-statement | http://www.guardian.co.uk/ |


    Scenario Outline: Attempt to get 404 URL
        Given an embedly endpoint
        When oembed is called with the <url> URL
        Then type should be error
        And error_code should be 404
        And type should be error

        Examples:
            | url                                                              |
            | http://www.youtube.com/watch/is/a/bad/url                        |
            | http://www.scribd.com/doc/zfldsf/asdfkljlas/klajsdlfkasdf        |
            | http://fav.me/alsfsdf                                            |
        

    Scenario Outline: Attempt multi get 404 URLs
        Given an embedly endpoint
        When oembed is called with the <urls> URLs
        Then error_code should be <errcode>
        And type should be <types>

        Examples:
            | urls                                                                             | errcode | types       |
            | http://www.youtube.com/watch/a/bassd/url,http://www.youtube.com/watch/ldf/asdlfj | 404,404 | error,error |
            | http://www.scribd.com/doc/lsbsdlfldsf/kl,http://www.scribd.com/doc/zasdf/asdfl   | 404,404 | error,error |
            | http://www.youtube.com/watch/zzzzasdf/kl,http://tweetphoto.com/14784358          | 404,    | error,photo |
            | http://tweetphoto.com/14784358,http://www.scribd.com/doc/asdfasdfasdf            | ,404    | photo,error |
        
    Scenario Outline: Attempt at non-api service without key
        Given an embedly endpoint
        When oembed is called with the <url> URL
        Then error_code should be 401
        And error_message should be This service requires an Embedly Pro account
        And type should be error

        Examples:
            | urls                                                                             | 
            | http://hn.embed.ly/                                                              | 
            | http://bit.ly/enZRxO                                                             | 
            | http://techcrunch.com/2011/02/03/linkedins-next-data-dive-professional-skills/   | 
            | http://teachertube.com/rssPhoto.php                                              | 
            | http://goo.gl/y1i9p                                                              | 
