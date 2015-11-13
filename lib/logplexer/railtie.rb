module Logplexer
  class Railtie < Rails::Railtie
    initializer "logplexer.configure_rails_initialization" do
      Logplexer.configure do |config|
        config.honeybadger = !(Rails.env == 'development' or Rails.env == 'test')
      end
    end
  end
end
