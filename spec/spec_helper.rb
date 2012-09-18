require 'bundler/setup'
Bundler.require

ENV['RACK_ENV'] = "test"
require "factory_girl"
require_relative '../lib/model/format_visits'
require_relative '../lib/datamapper_config'

Datainsight::Logging.configure(:env => :test)
DataMapperConfig.configure(:test)
FactoryGirl.find_definitions
