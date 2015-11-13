# Logplexer - Multiplex all the logs

Logplexer allows you to multiplex where your logs go depending on the environment: either standard out, log file or Honeybadger. This can be configured at initialize-time or runtime.

By default in a Rails app, it is set to log to standard out in `development` and `test` and log to Honeybadger in any other environment. As log as you have Honeybadger set up in your application this gem will work.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'logplexer'
```

or


    $ gem install logplexer

And then execute:

    $ bundle

## Usage

Logplexer is a wrapper for `Honeybadger.notify` or Ruby's `Logger` class with all the methods for the typical `Logger` class.

If you are in `development`, you can write:

```ruby
> Logplexer.info( Exception.new("Oh hai!") )
I, [2015-06-20T15:25:02.182916 #23463]  INFO -- : Oh hai!
=> nil
```

Or in `production`:

```ruby
> Logplexer.info( Exception.new("Oh hai!") )
=> "684f15d9-c8f6-4ad8-885d-3ee50f612305"
```

Which will call `Honeybadger.notify()`

Inputs can be any type, `Exception`, `String`, `Hash`, etc.

If you are in development and would like to log to a logfile, just specify a logfile in the opts argument like so:

```ruby
> Logplexer.info( "Oh hai!", logfile: '/Users/ryanc/Desktop/log.txt' )
 => true
```

```bash
cat ~/Desktop/log.txt
# Logfile created on 2015-06-20 15:49:16 -0700 by logger.rb/47272
I, [2015-06-20T15:49:16.040351 #23538]  INFO -- : Oh hai!
```

If you're using Rails, you can also specify the logger to be the Rails logger. In fact you can specify any class as the logger
so long as the instance responds to all the message types: `debug`, `info`, `warn`, `error`, and `fatal` which all instances of
`Logger` will.

```ruby
> Logplexer.error( "Log to Rails not STDOUT", logger: Rails.logger )
```

If you would like to see the whole backtrace, just set `verbose` to true like so:

```ruby
def method1
  begin
    raise "Holy errors Batman"
  rescue => e
    Logplexer.error( e, verbose: true )
  end
end

def method2
  method1
end

def method3
  method2
end

method3
```

```
E, [2015-06-21T16:04:59.247900 #25737] ERROR -- : Holy errors Batman
E, [2015-06-21T16:04:59.248003 #25737] ERROR -- : > /Users/ryanc/Workspace/test_logplexer/config/initializers/logplexer.rb:6:in `method1'
E, [2015-06-21T16:04:59.248024 #25737] ERROR -- : > /Users/ryanc/Workspace/test_logplexer/config/initializers/logplexer.rb:13:in `method2'
E, [2015-06-21T16:04:59.248041 #25737] ERROR -- : > /Users/ryanc/Workspace/test_logplexer/config/initializers/logplexer.rb:17:in `method3'
```

## Configuration

In most cases specifying logfile, logger, etc at the time of the logger call is fine, but I know there are many who need to fine tune their Logplexing capabilities. Logplexer exposes an array of configuration options that you can add to your `config/initializers/logplexer.rb` file.

A basic example of a logplexer initializer:

```ruby
Logplexer.configure do |config|
  # config.logfile = "my_sexy_log.log" # STDOUT by default, but if you set logger, this will be ignored.
  config.logger = Rails.logger # Logger.new(STDOUT) by default
  config.verbose = Rails.env == "development" # logs the backtrace as well
  # quiet = false # if true, nothing will log (helpful for tests)
  config.honeybadger = false # This tells Logplexer whether or not to log to Honeybadger
  config.min_log_level = :warn # :error by default. Can be ( :debug, :info, :warn, :error, or :fatal )
end
```

The default initializer is as follows:

```ruby
Logplexer.configure do |config|
  config.honeybadger = !(Rails.env == 'development' or Rails.env == 'test')
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rspec spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Fullscreen/logplexer.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
