require 'bundler/setup'
Bundler.require(:default, :test)

ENV['RACK_ENV'] = "test"
require "factory_girl"
require_relative "../lib/models"
require 'timecop'

Datainsight::Logging.configure(:env => :test)
::Logging.logger.root.level = :warn
FactoryGirl.find_definitions

RSpec.configure do |config|
  config.before(:all) do
    DataInsight::Recorder::DataMapperConfig.configure(:test)
    DataMapper.auto_migrate!
  end
  config.before(:each) do
    DatabaseCleaner.clean_with(:truncation)
  end
end
