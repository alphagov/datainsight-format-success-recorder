require_relative "../spec_helper"
require_relative "../../lib/recorder"

describe "ContentEngagementDetailRecorder" do
  before(:each) do
    @message = {
      :envelope => {
        :collected_at => "2013-02-12T11:51:43+00:00",
        :collector => "Google Analytics",
        :_routing_key => "google_analytics.content_engagement.weekly"
      },
      :payload => {
        :start_at => "2013-02-03T00:00:00+00:00",
        :end_at => "2013-02-10T00:00:00+00:00",
        :value => {
          :site => "govuk",
          :format => "smart_answer",
          :entries => 821,
          :successes => 398,
          :slug => "which-finance-is-right-for-your-business"
        }
      }
    }
    @recorder = FormatSuccess::Recorder.new
  end

  it "should store weekly content engagement entries when processing message" do
    @recorder.update_message(@message)
  
    ContentEngagementVisits.all.should_not be_empty
    item = ContentEngagementVisits.first
    item.entries.should == 821
    item.format.should == "smart_answer"
    item.slug.should == "which-finance-is-right-for-your-business"
    item.successes.should == 398
    item.start_at.should == DateTime.new(2013, 2, 3)
    item.end_at.should == DateTime.new(2013, 2, 10)
  end
  
  it "should correctly handle end date over month boundaries" do
    @message[:payload][:start_at] = "2011-08-25T00:00:00"
    @message[:payload][:end_at] = "2011-09-01T00:00:00"
    @recorder.update_message(@message)
    item = ContentEngagementVisits.first
    item.end_at.should == DateTime.new(2011, 9, 1)
  end
  
  it "should update existing measurements" do
    @recorder.update_message(@message)
    @message[:payload][:value][:entries] = 900
    @recorder.update_message(@message)
    ContentEngagementVisits.all.length.should == 1
    ContentEngagementVisits.first.entries.should == 900
  end
  
end
