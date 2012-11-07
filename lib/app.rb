require "bundler/setup"
Bundler.require(:default, :exposer)

require 'json'

require_relative "model/format_visits"
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

  {
    :response_info => {:status => "ok"},
    :id => "/format-success",
    :web_url => "",
    :details => {
      :source => ["Google Analytics"],
      :data => FormatVisits.get_latest_formats(SUPPORTED_FORMATS.keys).map { |format_visit|
        {
          :format => SUPPORTED_FORMATS[format_visit.format],
          :entries => format_visit.entries,
          :percentage_of_success => format_visit.percentage_of_success
        }
      }
    },
    :updated_at => FormatVisits.updated_at
  }.to_json
end

error do
  logger.error env['sinatra.error']
end
