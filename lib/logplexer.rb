require "logplexer/version"
require "honeybadger"
require 'logplexer/railtie' if defined?(Rails)
require 'logger'
require 'logplexer/configuration'
class LogplexerError < StandardError
end

module Logplexer
  extend self
  attr_writer :config
  def config
    @config ||= Configuration.new
  end

  def configure(&blk)
    yield( config )
  end
  # Dyamically create all the class log methods for Rails logger
  %W(debug info warn error fatal).each do |log_type|
    class_eval  <<-RUBY
      def #{log_type}(exception, **opts)
        log( exception, "#{log_type}", opts )
      end
    RUBY
  end

  def log( exception, log_level, **opts)
    # We wrap the Honeybadger notify call so that in development,
    # we actually see the errors. Then we can unwrap the REST errors
    # if need be

    return if exception.nil?
    return if Logplexer.config.quiet?

    # If the user specifies a logfile AND a logger in the call, the logger will win out
    logfile = opts.delete( :logfile ) || Logplexer.config.logfile
    logger = opts.delete( :logger ) || Logplexer.config.logger
    unless is_logger?(logger)
      raise LogplexerError, "If specified, logger must be able to respond to :debug, :info, :warn, :error, and :fatal"
    end

    # Override the verbosity if config.verbose is unset
    verbose = opts.delete( :verbose )
    verbose = verbose.nil? ? Logplexer.config.verbose? : verbose

    if Logplexer.config.honeybadger? && above_min_log_level?( log_level )

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

  def is_logger?(logger)
    eval( %w(debug info warn error fatal).map do |meth|
      "logger.respond_to?(:#{meth})"
    end.join( ' && ' ) )
  end
  def above_min_log_level?( p )
    min = Logplexer.config.min_log_level || :error
    return priority( p ) >= priority( min )
  end

  def priority( level )
    @priorities ||= { debug: 0, info: 1, warn: 2, error: 3, fatal: 4 }
    @priorities[ level.to_sym ]
  end

end
