require 'bundler/setup'
Bundler.require

ENV['RACK_ENV'] = "test"
require "factory_girl"
require_relative '../lib/model'
require_relative '../lib/content_engagement_visits'
require_relative '../lib/datamapper_config'

require 'timecop'

Datainsight::Logging.configure(:env => :test)
DataMapperConfig.configure(:test)
FactoryGirl.find_definitions

Spec::Runner.configure do |config|
  config.before(:each) do
    FormatSuccess::Model.destroy!
    ContentEngagementVisits.destroy!
  end
end
