require 'bundler/setup'
Bundler.require(:default, :test)

ENV['RACK_ENV'] = "test"
require "factory_girl"
require_relative '../lib/model/format_success'
require_relative '../lib/model/content_engagement_visits'
require_relative '../lib/datamapper_config'

require 'timecop'

Datainsight::Logging.configure(:env => :test)
::Logging.logger.root.level = :warn
DataMapperConfig.configure(:test)
FactoryGirl.find_definitions

RSpec.configure do |config|
  config.before(:each) do
    DatabaseCleaner.clean_with(:truncation)
  end
end
