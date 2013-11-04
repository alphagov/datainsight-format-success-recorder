module FormatSuccess
  class Model
    include DataMapper::Resource
    include DataInsight::Recorder::BaseFields
    include DataInsight::Recorder::TimeSeries

    property :start_at, DateTime, :required => true, :unique_index => :format_date_range
    property :end_at, DateTime, :required => true, :unique_index => :format_date_range

    property :entries, Integer, :required => true
    property :successes, Integer, :required => true
    property :format, String, :required => true, :unique_index => :format_date_range

    validates_with_method :validate_time_series_week

    validates_with_method :validate_entries_positive, :if => lambda { |m| m.entries.is_a?(Numeric) }
    validates_with_method :validate_successes_positive, :if => lambda { |m| m.successes.is_a?(Numeric) }
    validates_with_method :validate_entries_bigger_than_successes, :if => lambda { |m| m.entries.is_a?(Numeric) and m.successes.is_a?(Numeric) }

    validates_with_method :validate_start_at_in_past

    def self.update_from_message(message)
      query = {
        start_at: DateTime.parse(message[:payload][:start_at]),
        end_at: DateTime.parse(message[:payload][:end_at]),
        format: message[:payload][:value][:format]
      }
      record = Model.first(query)
      record = Model.new(query) unless record

      record.collected_at = DateTime.parse(message[:envelope][:collected_at])
      record.source = message[:envelope][:collector]
      record.entries = message[:payload][:value][:entries]
      record.successes = message[:payload][:value][:successes]
      begin
        record.save
      rescue DataMapper::SaveFailureError => e
        logger.error(e.resource.errors.inspect)
        raise
      end
    end

    def self.get_latest_formats(filter_by=nil)
      query = {
        :start_at.gte => max(:start_at)
      }
      query[:format] = filter_by unless filter_by.nil?
      all(query)
    end

    def self.updated_at
      max(:collected_at)
    end

    def percentage_of_success
      if entries == 0
        0.0
      else
        (successes.to_f / entries) * 100
      end
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

    def validate_entries_bigger_than_successes
      if self.entries >= self.successes
        true
      else
        [false, "entries should be bigger or equal to successes"]
      end
    end

    def validate_start_at_in_past
      if start_at.nil? || start_at <= Date.today
        true
      else
        [false, "The start at date should be in the past."]
      end
    end
  end
end
