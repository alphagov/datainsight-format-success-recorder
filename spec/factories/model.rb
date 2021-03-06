FactoryGirl.define do
  factory :format_success, class: FormatSuccess::Model do
    source "govuk"
    collected_at DateTime.new(2012, 9, 18, 11, 42, 23)
    start_at DateTime.new(2012, 9, 9)
    end_at DateTime.new(2012, 9, 16)
    entries 5000
    successes 4000
    format 'transaction'
  end
end