require "logplexer/version"
require "honeybadger"
require 'logplexer/railtie' if defined?(Rails)
require 'logger'
module Logplexer

  extend self

  # Dyamically create all the class log methods for Rails logger
  %W(debug info warn error fatal).each do |log_type|
    class_eval  <<-RUBY
      def #{log_type}(exception, opts = {})
        log( exception, "#{log_type}", opts )
      end
    RUBY
  end

  def log( exception, log_level, opts = {})
    # We wrap the Honeybadger notify call so that in development,
    # we actually see the errors. Then we can unwrap the REST errors
    # if need be
    return if exception.nil?
    return if ENV['LOG_QUIET'] == 'true'

    logfile = opts.delete( :logfile )
    logger = Logger.new( logfile || STDOUT )

    # Override the verbosity if LOG_VERBOSE is unset
    verbose = ENV["LOG_VERBOSE"] == "true" ? true : opts.delete( :verbose )
    if ENV['LOG_TO_HB'] == "true" && above_min_log_level?( log_level )
      #TODO: Maybe extend this to include other kinds of notifiers.
      if exception.is_a? String
        exception = { error_class: "Exception",
                      error_message: exception }
      end
      Honeybadger.notify( exception, opts )
    else
      # Make sure that the exception is an actual exception and
      # not just a hash since Honeybadger accepts both
      if exception.is_a? Exception
        logger.send( log_level, exception.message )
        if verbose
          exception.backtrace.each do |entry|
            logger.send( log_level, "> #{entry}" )
          end
        end

      elsif exception.is_a? String
        # Log just the string if thats what the user wants
        logger.send( log_level, exception )

      else
        # Default kind of log for an object or whatevs
        logger.send( log_level, exception.inspect )
      end
    end
  end

  def above_min_log_level?( p )
    min = ENV["LOG_MIN_HB"] || 'error'
    return priority( p ) >= priority( min )
  end

  def priority( level )
    @priorities ||= { debug: 0, info: 1, warn: 2, error: 3, fatal: 4 }
    @priorities[ level.to_sym ]
  end

end
