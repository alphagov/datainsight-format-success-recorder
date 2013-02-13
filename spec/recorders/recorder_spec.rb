require_relative "../spec_helper"
require_relative "../../lib/recorder"

describe "Recorder" do
  before(:each) do
    @recorder = FormatSuccess::Recorder.new
  end

  it "should update an artefact" do
    message = {
        envelope: {
            _routing_key: "govuk.artefacts"
        }
    }

    Artefact.should_receive(:update_from_message).with(message)

    @recorder.update_message(message)
  end

  it "should update format success" do
    message = {
        envelope: {
            _routing_key: "google_analytics.entry_and_success.weekly"
        }
    }

    FormatSuccess::Model.should_receive(:update_from_message).with(message)

    @recorder.update_message(message)
  end

  it "should update content engagement" do
    message = {
        envelope: {
            _routing_key: "google_analytics.content_engagement.weekly"
        }
    }

    ContentEngagementVisits.should_receive(:update_from_message).with(message)

    @recorder.update_message(message)
  end

end
