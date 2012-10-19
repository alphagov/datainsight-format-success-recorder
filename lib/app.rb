require "bundler/setup"
Bundler.require(:default, :exposer)

require 'json'

require_relative "model/format_visits"
require_relative "format_success"
require_relative "datamapper_config"

helpers Datainsight::Logging::Helpers

SUPPORTED_FORMATS = { 
  "guide" => "Guides",
  #"transaction" => "Transactions",
  "programme" => "Benefits",
  "answer" => "Quick Answers",
  "smart_answer" => "Smart Answers"
}

configure do
  enable :logging
  unless test?
    Datainsight::Logging.configure(:type => :exposer)
    DataMapperConfig.configure
  end
end

get '/format-success' do
  content_type :json
  FormatSuccess.new.format_success(SUPPORTED_FORMATS).to_json
end

error do
  logger.error env['sinatra.error']
end
