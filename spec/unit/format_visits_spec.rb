require "date"

require_relative "../spec_helper"
require_relative "../../lib/format_success"

describe "Format Visits" do

  before(:each) do
  end

  it "should be saved to db" do
    format_visit = FactoryGirl.build(:format_visits)

    format_visit.save

    FormatVisits.get(format_visit.id).should_not be_nil
  end

  describe "validations" do
    it "should be valid" do
      format_visit = FactoryGirl.build(:format_visits)

      format_visit.should be_valid
    end

    it "should not be valid if collected at is nil" do
      format_visit = FactoryGirl.build(:format_visits, :collected_at => nil)

      format_visit.should_not be_valid
    end

    describe "start and end date" do
      it "should not be valid if start at is nil" do
        format_visit = FactoryGirl.build(:format_visits, :start_at => nil)

        format_visit.should_not be_valid
      end

      it "should not be valid if end at is nil" do
        format_visit = FactoryGirl.build(:format_visits, :end_at => nil)

        format_visit.should_not be_valid
      end

      it "should be valid if date range is a week" do
        format_visit = FactoryGirl.build(:format_visits,
                                         :start_at => Date.new(2012, 9, 16),
                                         :end_at => Date.new(2012, 9, 22))

        format_visit.should be_valid
      end

      it "should not be valid if date range is only 6 days" do
        format_visit = FactoryGirl.build(:format_visits,
                                         :start_at => Date.new(2012, 9, 16),
                                         :end_at => Date.new(2012, 9, 21))

        format_visit.should_not be_valid
      end

      it "should not be valid if date range is 8 days" do
        format_visit = FactoryGirl.build(:format_visits,
                                         :start_at => Date.new(2012, 9, 16),
                                         :end_at => Date.new(2012, 9, 23))

        format_visit.should_not be_valid
      end

      it "should not be valid if start at is a monday" do
        format_visit = FactoryGirl.build(:format_visits,
                                         :start_at => Date.new(2012, 9, 17),
                                         :end_at => Date.new(2012, 9, 23))

        format_visit.should_not be_valid
      end
    end

    describe "entries" do

      it "should not be valid if not present" do
        format_visit = FactoryGirl.build(:format_visits, :entries => nil)

        format_visit.should_not be_valid
      end

      it "should not be valid if is not integer" do
        format_visit = FactoryGirl.build(:format_visits, :entries => "no_integer")

        format_visit.should_not be_valid
      end

      it "should not be valid if negative" do
        format_visit = FactoryGirl.build(:format_visits, :entries => -1)

        format_visit.should_not be_valid
      end

      it "should be valid if zero" do
        format_visit = FactoryGirl.build(:format_visits, :entries => 0, :successes => 0)

        format_visit.should be_valid
      end

    end

    describe "successes" do

      it "should not be valid if not present" do
        format_visit = FactoryGirl.build(:format_visits, :successes => nil)

        format_visit.should_not be_valid
      end

      it "should not be valid if is not integer" do
        format_visit = FactoryGirl.build(:format_visits, :successes => "no_integer")

        format_visit.should_not be_valid
      end

      it "should not be valid if negative" do
        format_visit = FactoryGirl.build(:format_visits, :successes => -1)

        format_visit.should_not be_valid
      end

      it "should not be valid if equal to entries" do
        format_visit = FactoryGirl.build(:format_visits, :entries => 10, :successes => 10)

        format_visit.should be_valid
      end

      it "should not be valid if bigger than entries" do
        format_visit = FactoryGirl.build(:format_visits, :entries => 10, :successes => 20)

        format_visit.should_not be_valid
      end

      it "should be valid if zero" do
        format_visit = FactoryGirl.build(:format_visits, :successes => 0)

        format_visit.should be_valid
      end
    end

  end

  after(:each) do
    FormatVisits.destroy!
  end
end
