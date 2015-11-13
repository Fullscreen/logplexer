require 'logger'

module Logplexer
  class Configuration
    attr_accessor :logger, :verbose, :quiet, :honeybadger, :min_log_level
    attr_reader :logfile
    def initialize
      @logfile = STDOUT
      @logger = Logger.new(STDOUT)
      @verbose = false
      @quiet = false
      @honeybadger = false
      @min_log_level = :error
    end

    def logfile=( val )
      @logfile = val
      @logger = Logger.new( val )
      @logfile
    end

    %w(honeybadger quiet verbose).each do |question|
      class_eval  <<-RUBY
        def #{question}?
          #{question}
        end
      RUBY
    end
  end
end
