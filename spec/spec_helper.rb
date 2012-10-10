require 'bundler/setup'
Bundler.require

ENV['RACK_ENV'] = "test"
require "factory_girl"
require_relative '../lib/model/format_visits'
require_relative '../lib/format_success'
require_relative '../lib/datamapper_config'

require 'timecop'

Datainsight::Logging.configure(:env => :test)
DataMapperConfig.configure(:test)
FactoryGirl.find_definitions
