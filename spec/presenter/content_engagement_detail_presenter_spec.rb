require_relative "../spec_helper"
require_relative "../../lib/model/content_engagement_visits"
require_relative "../../lib/presenter/content_engagement_detail_presenter"

describe ContentEngagementDetailPresenter do
  it "should create a content engagement detail response from a list of content engagement visits" do
    artefact = FactoryGirl.build(:artefact, format: "guide", slug: "apply-for-visa", title: "Apply for Visa", url: "http://apply-for-visa")
    list_of_content_engagement_visits = [
        FactoryGirl.build(:content_engagement_visits, artefact: artefact),
        FactoryGirl.build(:content_engagement_visits, artefact: artefact)
    ]

    response = ContentEngagementDetailPresenter.new.present(list_of_content_engagement_visits)

    response[:details][:data].should have(2).items
  end

  it "should create a content engagement detail response with correct data format" do
    artefact = FactoryGirl.build(:artefact, format: "guide", slug: "apply-for-visa", title: "Apply for Visa", url: "http://apply-for-visa")

    list_of_content_engagement_visits = [
        FactoryGirl.build(:content_engagement_visits, artefact: artefact)
    ]

    response = ContentEngagementDetailPresenter.new.present(list_of_content_engagement_visits)

    response[:details][:data].first[:format].should == "guide"
    response[:details][:data].first[:slug].should == "apply-for-visa"
    response[:details][:data].first[:entries].should == 10000
    response[:details][:data].first[:successes].should == 5000
    response[:details][:data].first[:title].should == "Apply for Visa"
    response[:details][:data].first[:url].should == "http://apply-for-visa"

  end

  it "should create a content engagement detail response with standard metadata" do
    artefact = FactoryGirl.build(:artefact, format: "guide", slug: "apply-for-visa", title: "Apply for Visa", url: "http://apply-for-visa")
    list_of_content_engagement_visits = [
      FactoryGirl.build(:content_engagement_visits, artefact: artefact)
    ]

    response = ContentEngagementDetailPresenter.new.present(list_of_content_engagement_visits)

    response[:details][:start_at].should == "2013-01-13T00:00:00+00:00"
    response[:details][:end_at].should == "2013-01-20T00:00:00+00:00"
    response[:details][:source].should == ["Google Analytics"]
    response[:updated_at].should == "2013-01-21T00:00:00+00:00"
  end

  it "should normally mark response as ok" do
    artefact = FactoryGirl.build(:artefact, format: "guide", slug: "apply-for-visa", title: "Apply for Visa", url: "http://apply-for-visa")
    list_of_content_engagement_visits = [
      FactoryGirl.build(:content_engagement_visits, artefact: artefact)
    ]

    response = ContentEngagementDetailPresenter.new.present(list_of_content_engagement_visits)

    response[:response_info][:status].should == "ok"
  end

  it "should return nil entries and successes if entries are below 1000" do
    data = [
      FactoryGirl.build(:content_engagement_visits, entries: 1200, successes: 1100, artefact: FactoryGirl.build(:artefact)),
      FactoryGirl.build(:content_engagement_visits, entries: 1000, successes:  550, artefact: FactoryGirl.build(:artefact)),
      FactoryGirl.build(:content_engagement_visits, entries:  999, successes: 1100, artefact: FactoryGirl.build(:artefact)),
    ]

    response = ContentEngagementDetailPresenter.new.present(data)

    response[:details][:data][0][:entries].should == 1200
    response[:details][:data][0][:successes].should == 1100

    response[:details][:data][1][:entries].should == 1000
    response[:details][:data][1][:successes].should == 550

    response[:details][:data][2][:entries].should be_nil
    response[:details][:data][2][:successes].should be_nil
  end

  it "should fail if start_at vary among given objects" do
    list_of_content_engagement_visits = [
        FactoryGirl.build(:content_engagement_visits,
                          :start_at => Date.new(2012, 7, 1), :end_at => Date.new(2012, 7, 15)),
        FactoryGirl.build(:content_engagement_visits,
                          :start_at => Date.new(2012, 7, 8), :end_at => Date.new(2012, 7, 15)),
    ]

    lambda { ContentEngagementDetailPresenter.new.present(list_of_content_engagement_visits) }.should raise_exception
  end

  it "should fail if end_at vary among given objects" do
    list_of_content_engagement_visits = [
        FactoryGirl.build(:content_engagement_visits,
                          :start_at => Date.new(2012, 7, 1), :end_at => Date.new(2012, 7, 7)),
        FactoryGirl.build(:content_engagement_visits,
                          :start_at => Date.new(2012, 7, 1), :end_at => Date.new(2012, 7, 15)),
    ]

    lambda { ContentEngagementDetailPresenter.new.present(list_of_content_engagement_visits) }.should raise_exception
  end
end