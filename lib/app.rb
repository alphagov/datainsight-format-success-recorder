require "bundler/setup"
Bundler.require(:default, :exposer)

require 'json'

require_relative "model"
require_relative "datamapper_config"
require_relative "initializers"

helpers Datainsight::Logging::Helpers

use Airbrake::Rack
enable :raise_errors

# Add format codes here to add them to the response.
SUPPORTED_FORMATS = %w(guide programme answer smart_answer)

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
      :data => FormatSuccess::Model.get_latest_formats(SUPPORTED_FORMATS).map { |format_success|
        {
          :format => format_success.format,
          :entries => format_success.entries,
          :percentage_of_success => format_success.percentage_of_success
        }
      }
    },
    :updated_at => FormatSuccess::Model.updated_at
  }.to_json
end

error do
  logger.error env['sinatra.error']
end
