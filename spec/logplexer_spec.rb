require 'spec_helper'

describe Logplexer do
  before do
    allow_any_instance_of( Logger ).to receive(:debug).and_return(true)
    allow_any_instance_of( Logger ).to receive(:info).and_return(true)
    allow_any_instance_of( Logger ).to receive(:warn).and_return(true)
    allow_any_instance_of( Logger ).to receive(:error).and_return(true)
    allow_any_instance_of( Logger ).to receive(:fatal).and_return(true)
  end

  it 'has a version number' do
    expect(Logplexer::VERSION).not_to be nil
  end

  it 'should respond to all methods created through meta' do
    expect(Logplexer.respond_to? :debug).to eq( true )
    expect(Logplexer.respond_to? :info).to eq( true )
    expect(Logplexer.respond_to? :warn).to eq( true )
    expect(Logplexer.respond_to? :error).to eq( true )
    expect(Logplexer.respond_to? :fatal).to eq( true )
  end

  it 'should log to STDOUT' do
    expect_any_instance_of(Logger).to receive(:error).with("WAT")
    Logplexer.error("WAT")
  end

  it 'should handle hashes as exceptions' do
    h = {a: "hello", b: "world"}
    expect_any_instance_of(Logger).to receive(:info).with(h.inspect)
    Logplexer.info(h)
  end

  it 'should handle backtrace on verbose' do
    ex = Exception.new("Much error, many wrongs")
    allow(ex).to receive(:backtrace).and_return(["stackity"])
    expect_any_instance_of(Logger).to receive(:warn).with("Much error, many wrongs")
    expect_any_instance_of(Logger).to receive(:warn).with("> stackity")
    Logplexer.warn( ex, { verbose: true })
  end

  it 'should handle verbosity set on environment' do
    ex = Exception.new("Much error, many wrongs")
    allow(ex).to receive(:backtrace).and_return(["stackity"])
    expect_any_instance_of(Logger).to receive(:warn).with("Much error, many wrongs")
    expect_any_instance_of(Logger).to receive(:warn).with("> stackity")
    Logplexer.config.verbose = true
    Logplexer.warn( ex )
  end
  it 'should log to Honeybadger' do
    Logplexer.config.honeybadger = true
    VCR.use_cassette('honeybadger') do
      reg = /[a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12}/
      expect { Logplexer.error('the error').to match( reg ) }
    end
  end

  it 'should turn a string into a hash for HB' do
    exception = { error_class: "Exception",
                  error_message: "Oh hai" }
    expect(Honeybadger).to receive(:notify).with( exception, {} )
    Logplexer.error("Oh hai")
  end

  it 'should only log to HB if LOG_MIN_HB is gte a set value' do
    Logplexer.configure { |c| c.honeybadger = true; c.min_log_level = :info}
    VCR.use_cassette('honeybadger') do
      reg = /[a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12}/
      expect { Logplexer.info('the error').to match( reg ) }
    end
    Logplexer.config = Logplexer::Configuration.new
  end

  it 'should not log any errors if LOG_QUIET is true' do
    Logplexer.config.quiet = true
    expect_any_instance_of( Logger ).not_to receive(:error).with('do you even logplex bro?')
    Logplexer.error('do you even logplex bro?')
    Logplexer.config.quiet = false
  end

  it 'should handle named args as well as hash' do
    expect(Logplexer).to receive(:log).with("Yo", "warn", { verbose: true })
    Logplexer.warn("Yo", verbose: true )
  end

  # TODO: Get this spec working. Tested out in console/ working fine
  # it 'should log to a file' do
  #   msg = "This one time at band camp..."
  #   Logplexer.info(msg, logfile: "blah.log")
  #   expect(Logger).to receive(:new)
  # end

  it 'should be able to pass in a custom logger' do
    railslogger = Logger.new(STDOUT)
    expect(Logplexer).to receive(:log).with("some message", "error", {logger: railslogger})
    Logplexer.error("some message", logger: railslogger)
  end

  it 'should raise an error if the custom logger doesnt respond to all methods' do
    badlogger = Hash.new # doesnt respond to :error, :info, etc
    begin
      Logplexer.error("some message", logger: badlogger)
      raise "Allowed Logger to be called with a bad logger"
    rescue => e
      expect(e.message).to eq("If specified, logger must be able to respond to :debug, :info, :warn, :error, and :fatal")
    end
  end
end
