require "spec_helper"
require_relative "../lib/model/content_engagement_visits"

describe ContentEngagementVisits do
  describe "last_week_visits" do
    it "should return visits for the available week" do
      FactoryGirl.create(:artefact, format: "guide", slug: "foo")
      FactoryGirl.create(:artefact, format: "guide", slug: "bar")
      FactoryGirl.create(:artefact, format: "guide", slug: "alfa")

      FactoryGirl.create(:content_engagement_visits, slug: "foo", format: "guide",
                         start_at: DateTime.new(2012, 7, 1), end_at: DateTime.new(2012, 7, 8))
      FactoryGirl.create(:content_engagement_visits, slug: "bar", format: "guide",
                         start_at: DateTime.new(2012, 7, 1), end_at: DateTime.new(2012, 7, 8))

      older_item = FactoryGirl.create(:content_engagement_visits, slug: "alfa", format: "guide",
                                      start_at: DateTime.new(2012, 6, 24), end_at: DateTime.new(2012, 7, 1))

      content_engagement_visits = ContentEngagementVisits.last_week_visits

      content_engagement_visits.should_not include(older_item)
    end

    it "should return visits together with artefact details" do
      FactoryGirl.create(:content_engagement_visits, format: "guide", slug: "foo",
                         start_at: DateTime.new(2012, 7, 1), end_at: DateTime.new(2012, 7, 8))
      FactoryGirl.create(:artefact, format: "guide", slug: "foo", title: "Foo title", url: "https://www.gov.uk/foo")

      content_engagement_visits = ContentEngagementVisits.last_week_visits

      content_engagement_visits.should have(1).items
      content_engagement_visits.first.artefact.slug.should == "foo"
      content_engagement_visits.first.artefact.title.should == "Foo title"
      content_engagement_visits.first.artefact.url.should == "https://www.gov.uk/foo"
    end

    it "should not return visits that do not have a matching artefact" do
      artefact = FactoryGirl.create(:artefact, format: "guide", slug: "driving-on-the-right-side")
      FactoryGirl.create(:content_engagement_visits, format: "guide", slug: "driving-on-the-right-side", artefact: artefact)
      FactoryGirl.create(:content_engagement_visits, format: "programme", slug: "an-unknown-slug", artefact: nil)

      content_engagement_visits = ContentEngagementVisits.last_week_visits

      content_engagement_visits.should have(1).item
    end

    it "should return data for artefacts with 0 visits and successes" do
      FactoryGirl.create(:artefact, format: "guide", slug: "very-unpopular-guide", title: "Very unpopular guide")
      artefact = FactoryGirl.create(:artefact, format: "guide", slug: "driving-on-the-right-side")

      FactoryGirl.create(:content_engagement_visits, format: "guide", slug: "driving-on-the-right-side", artefact: artefact, start_at: DateTime.new(2013, 2, 10), end_at: DateTime.new(2013, 2, 17))

      content_engagement_visits = ContentEngagementVisits.last_week_visits

      content_engagement_visits.should have(2).items

      unpopular_guide_visits = content_engagement_visits.find {|v| v.format == "guide" && v.slug == "very-unpopular-guide"}
      unpopular_guide_visits.should_not be_nil
      unpopular_guide_visits.entries.should == 0
      unpopular_guide_visits.successes.should == 0
      unpopular_guide_visits.start_at.should == DateTime.new(2013,2,10)
      unpopular_guide_visits.end_at.should == DateTime.new(2013,2,17)

      unpopular_guide_visits.artefact.title.should == "Very unpopular guide"
    end
  end

  describe "validation" do
    it "should not allow nil slug" do
      content_engagement_visits = FactoryGirl.build(:content_engagement_visits, slug: nil)
      content_engagement_visits.should_not be_valid
    end

    it "should not allow nil format" do
      content_engagement_visits = FactoryGirl.build(:content_engagement_visits, format: nil)
      content_engagement_visits.should_not be_valid
    end

    it "should not allow nil entries" do
      content_engagement_visits = FactoryGirl.build(:content_engagement_visits, entries: nil)
      content_engagement_visits.should_not be_valid
    end

    it "should not allow negative entries" do
      content_engagement_visits = FactoryGirl.build(:content_engagement_visits, entries: -2)
      content_engagement_visits.should_not be_valid
    end

    it "should not allow nil successes" do
      content_engagement_visits = FactoryGirl.build(:content_engagement_visits, successes: nil)
      content_engagement_visits.should_not be_valid
    end

    it "should not allow negative successes" do
      content_engagement_visits = FactoryGirl.build(:content_engagement_visits, successes: -1)
      content_engagement_visits.should_not be_valid
    end
  end
end
