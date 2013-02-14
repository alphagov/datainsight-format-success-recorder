require "spec_helper"
require_relative "../lib/model/artefact"

describe Artefact do
  describe "update from message" do
    before(:each) do
      @message = {
          :envelope => {
              :collected_at => "2012-12-12T00:00:00",
              :collector => "GOV.UK",
              :_routing_key => "govuk.artefacts"
          },
          :payload => {
              :format => "guide",
              :title => "How to apply for student finance",
              :id => "https://www.gov.uk/api/apply-for-student-finance.json",
              :web_url => "https://www.gov.uk/apply-for-student-finance"
          }
      }
    end

    it "should insert a new record" do
      Artefact::update_from_message(@message)

      records = Artefact.all

      records.should have(1).item

      artefact = records.first
      artefact.source.should == "GOV.UK"
      artefact.collected_at.should == DateTime.new(2012, 12, 12)
      artefact.format.should == "guide"
      artefact.title.should == "How to apply for student finance"
      artefact.url.should == "https://www.gov.uk/apply-for-student-finance"
      artefact.slug.should == "apply-for-student-finance"
    end

    it "should update an existing record with the same format and slug" do
      FactoryGirl.create(:artefact, slug: "apply-for-student-finance", format: "guide", title: "Old title")

      Artefact::update_from_message(@message)

      records = Artefact.all

      records.should have(1).item

      records.first.title.should == "How to apply for student finance"
    end
  end
end