require_relative "spec_helper"
require_relative "../lib/recorder"

describe "FormatSuccessRecorder" do


  before(:each) do
    @message = {
        :envelope => {
            :collected_at => "2012-09-18T13:51:59+00:00",
            :collector => "Google Analytics",
            :_routing_key => "google_analytics.entry_and_success.weekly"
        },
        :payload => {
            :start_at => "2012-09-09T00:00:00+00:00",
            :end_at => "2012-09-16T00:00:00+00:00",
            :value => {
              :site => "govuk",
              :format => "transaction",
              :entries => 10792,
              :successes => 0
            }
        }
    }

    @recorder = FormatSuccess::Recorder.new
  end

  after(:each) do
    FormatSuccess::Model.destroy
  end

  it "should store a valid message" do
    @recorder.update_message(@message)

    format_visits = FormatSuccess::Model.first
    format_visits.should_not be_nil
    format_visits.collected_at.should == DateTime.parse(@message[:envelope][:collected_at])
    format_visits.start_at.should     == DateTime.new(2012, 9, 9)
    format_visits.end_at.should       == DateTime.new(2012, 9, 16)
    format_visits.format.should       == @message[:payload][:value][:format]
    format_visits.entries.should      == @message[:payload][:value][:entries]
    format_visits.successes.should    == @message[:payload][:value][:successes]
  end

  it "should update existing measurements" do
    @recorder.update_message(@message)

    updated_message = @message
    updated_message[:payload][:value][:entries] = 12792
    updated_message[:payload][:value][:successes] = 50

    @recorder.update_message(updated_message)

    records = FormatSuccess::Model.all

    records.should have(1).item

    format_visits = records.first
    format_visits.entries.should == 12792
    format_visits.successes.should == 50
  end

  describe "validation" do
    it "should raise an error if model is invalid" do
      FormatSuccess::Model.any_instance.stub(:save).and_raise(DataMapper::SaveFailureError.new(nil, nil))

      lambda {
        @recorder.update_message(@message)
      }.should raise_error(DataMapper::SaveFailureError)
    end
  end
end
