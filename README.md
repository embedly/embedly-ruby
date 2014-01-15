# embedly

embedly is the Embedly Ruby client library and commandline tool.  It allows
you to integrate Embedly into your Ruby applications, as well as use
Embedly's API from the commandline.

To find out what Embedly is all about, please visit http://embed.ly.  To see
our api documentation, visit http://api.embed.ly/docs.

## Installing

To install the official latest stable version, please use rubygems.

    gem install embedly

If you would like cutting edge, then you can clone and install HEAD.

    git clone git://github.com/embedly/embedly-ruby.git
    cd embedly-ruby
    rake install

## Requirements

* querystring <https://github/dokipen/querystring>

## Getting Started

You can find rdocs at http://rubydoc.info/github/embedly/embedly-ruby/master/frames

```ruby
require 'embedly'
require 'json'

embedly_api =
  Embedly::API.new :user_agent => 'Mozilla/5.0 (compatible; mytestapp/1.0; my@email.com)'

# single url
obj = embedly_api.oembed :url => 'http://www.youtube.com/watch?v=sPbJ4Z5D-n4&feature=topvideos'
puts obj[0].marshal_dump
json_obj = JSON.pretty_generate(obj[0].marshal_dump)
puts json_obj

# multiple urls with opts
objs = embedly_api.oembed(
  :urls => ['http://www.youtube.com/watch?v=sPbJ4Z5D-n4&feature=topvideos',
            'http://twitpic.com/3yr7hk'],
  :maxwidth => 450,
  :wmode => 'transparent',
  :method => 'after'
)
json_obj = JSON.pretty_generate(objs.collect{|o| o.marshal_dump})
puts json_obj

# call api with key (you'll need a real key)
embedly_api = Embedly::API.new :key => 'xxxxxxxxxxxxxxxxxxxxxxxxxx',
        :user_agent => 'Mozilla/5.0 (compatible; mytestapp/1.0; my@email.com)'
url = 'http://www.guardian.co.uk/media/2011/jan/21/andy-coulson-phone-hacking-statement'
obj = embedly_api.extract :url => url
puts JSON.pretty_generate(obj[0].marshal_dump)
```

## Configuration options

You can configure some parameters in the api:

```ruby
Embedly.configure do |config|
 # prints debug messages to the logger
 config.debug = true

 # use a custom logger
 config.logger = MyAwesomeLogger.new(STDERR)

 # Choose a request adatper (net_http, typhoeus or faraday)
 config.request_with :faraday
end
```

## Testing

    gem install jeweler
    rake spec
    rake features # if it complains of missing deps install them

Some tests will fail due to missing api key.  Set the `EMBEDLY_KEY` environmental
variable with your key to get them to pass.

    EMBEDLY_KEY=xxxxxxxxxxxxx rake features

To turn on debugging, set the `EMBEDLY_VERBOSE` environmental variable.

    EMBEDLY_VERBOSE=1 EMBEDLY_KEY=xxxxxxxxxxx rake features

We have provided some commandline tools to test the Embedly interface.

* embedly_oembed
* embedly_objectify
* embedly_preview

Using `--help` with the commands should give you a good idea of how to use them.

## Note on Patches/Pull Requests

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2011 Embed.ly, Inc. See MIT-LICENSE for details.
