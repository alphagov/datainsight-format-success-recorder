require "dm-core"
require "dm-timestamps"
require "dm-validations"
require "dm-aggregates"

class FormatVisits
  include DataMapper::Resource
  property :id, Serial

  property :created_at, DateTime # When this measurement was first seen
  property :collected_at, DateTime, :required => true # When this measurement was collected
  property :updated_at, DateTime # When this measurement was last saved to the database

  property :start_at, DateTime, :required => true
  property :end_at, DateTime, :required => true
  property :entries, Integer, :required => true
  property :successes, Integer, :required => true
  property :format, String, :required => true

end