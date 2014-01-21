Feature: Command line runner
  As an embedly user
  I want to call the the embedly api via command line

  Scenario: Run oembed command
    When I run `embedly_oembed http://lockerz.com/s/136425091`
    Then the output should contain:
      """
      "provider_url": "http://pics.lockerz.com"
      """

  Scenario: Run oembed command verbosely
    When I run `embedly_oembed -v http://lockerz.com/s/136425091`
    Then the output should contain:
      """
      DEBUG -- : calling http://api.embed.ly/1/oembed
      """
