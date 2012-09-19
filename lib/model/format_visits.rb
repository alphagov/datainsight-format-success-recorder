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

  property :start_at, Date, :required => true
  property :end_at, Date, :required => true
  property :entries, Integer, :required => true
  property :successes, Integer, :required => true
  property :format, String, :required => true

  validates_uniqueness_of :format, :start_at, :end_at

  validates_with_method :validate_entries_positive, :if => lambda { |m| m.entries.is_a?(Numeric) }
  validates_with_method :validate_successes_positive, :if => lambda { |m| m.successes.is_a?(Numeric) }
  validates_with_method :validate_success_bigger_than_entries, :if => lambda { |m| m.entries.is_a?(Numeric) and m.successes.is_a?(Numeric) }

  validates_with_method :validate_week_length, :if => lambda { |m| (not m.start_at.nil?) and (not m.end_at.nil?) }
  validates_with_method :validate_week_starts_on_sunday, :if => lambda { |m| not m.start_at.nil? }

  def self.get_latest_formats
    all(:start_at => max(:start_at))
  end


  private
  def validate_positive field
    if self[field] >= 0
      true
    else
      [false, "#{field} must not be nil"]
    end
  end

  def validate_entries_positive
    validate_positive(:entries)
  end

  def validate_successes_positive
    validate_positive(:successes)
  end

  def validate_success_bigger_than_entries
    if self.entries >= self.successes
      true
    else
      [false, "entries should be bigger or equal to successes"]
    end
  end

  def validate_week_starts_on_sunday
    if self.start_at.sunday?
      true
    else
      [false, "start_at should always be Sunday."]
    end
  end

  def validate_week_length
    if (self.end_at - self.start_at) == 6
      true
    else
      [false, "The time between start at and end at should be a week."]
    end
  end
end