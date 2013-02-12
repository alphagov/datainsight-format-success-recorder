require 'bundler/setup'
Bundler.require(:default, :test)

ENV['RACK_ENV'] = "test"
require "factory_girl"
require_relative '../lib/model'
require_relative '../lib/content_engagement_visits'
require_relative '../lib/datamapper_config'

require 'timecop'

Datainsight::Logging.configure(:env => :test)
DataMapperConfig.configure(:test)
FactoryGirl.find_definitions

RSpec.configure do |config|
  config.before(:each) do
    DatabaseCleaner.clean_with(:truncation)
  end
end
