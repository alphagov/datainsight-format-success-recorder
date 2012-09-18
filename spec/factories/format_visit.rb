require_relative "../../lib/datamapper_config"

FactoryGirl.define do
  factory :format_visits, class: FormatVisits do
        collected_at DateTime.new(2012, 9, 18, 11, 42, 23)
        start_at DateTime.new(2012, 9, 9)
        end_at DateTime.new(2012, 9, 15)
        entries 5000
        successes 4000
        format 'MS_transaction'
  end
end