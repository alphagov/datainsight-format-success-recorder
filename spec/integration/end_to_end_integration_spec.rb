require_relative "spec_helper"
require_relative "../../lib/recorder"

describe "end to end integration" do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  before(:each) do

    @message = {
      :envelope => {
        :collected_at => "2012-09-18T13:51:59+01:00",
        :collector => "Google Analytics"
      },
      :payload => {
        :start_at => "2012-09-09T00:00:00+00:00",
        :end_at => "2012-09-16T00:00:00+00:00",
        :value => {
          :site => "govuk",
          :format => "guide",
          :entries => 10792,
          :successes => 12
        }
      }
    }

    FormatSuccess::Recorder.send(:public, :update_message)
    @recorder = FormatSuccess::Recorder.new
  end

  after(:each) do
    FormatSuccess::Model.destroy
  end

  it "should process a message and then expose it" do
    @recorder.update_message(@message)

    get "/format-success"

    last_response.should be_ok

    data = JSON.parse(last_response.body)["details"]["data"]
    data.should be_an(Array)
    data.first["entries"].should == 10792
  end
end