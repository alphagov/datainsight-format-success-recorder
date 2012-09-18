require_relative "../spec_helper"
require_relative "../../lib/recorders/format_success"

describe "FormatSuccessRecorder" do


  before(:each) do
    @message = {
        :envelope => {
            :collected_at => "2012-09-18T13:51:59+01:00",
            :collector => "Google Analytics"
        },
        :payload => {
            :start_at => "2012-09-09T00:00:00+00:00",
            :end_at => "2012-09-16T00:00:00+00:00",
            :site => "govuk",
            :format => "MS_transaction",
            :entries => 10792,
            :successes => 0
        }
    }

    Recorders::FormatSuccessRecorder.send(:public, :process_message)
    @recorder = Recorders::FormatSuccessRecorder.new
  end

  after(:each) do
    FormatVisits.destroy
  end

  it "should store valid message" do
    @recorder.process_message(@message)

    format_visits = FormatVisits.first
    format_visits.should_not be_nil
    format_visits.collected_at.should == DateTime.parse(@message[:envelope][:collected_at])
    format_visits.start_at.should     == Date.new(2012, 9, 9)
    format_visits.end_at.should       == Date.new(2012, 9, 15)
    format_visits.format.should       == @message[:payload][:format]
    format_visits.entries.should      == @message[:payload][:entries]
    format_visits.successes.should    == @message[:payload][:successes]
  end

  it "should update existing measurements" do
    @recorder.process_message(@message)

    updated_message = @message
    updated_message[:payload][:entries] = 12792
    updated_message[:payload][:successes] = 50

    @recorder.process_message(updated_message)

    FormatVisits.all.should have(1).item

    format_visits = FormatVisits.first
    format_visits.entries.should == 12792
    format_visits.successes.should == 50
  end

  describe "validation" do
    it "should raise an error if model is invalid" do
      FormatVisits.stub(:create).and_raise(DataMapper::SaveFailureError.new(nil, nil))

      lambda {
        @recorder.process_message(@message)
      }.should raise_error(DataMapper::SaveFailureError)
    end
  end
end
