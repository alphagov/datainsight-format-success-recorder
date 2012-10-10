require "date"

require_relative "../spec_helper"
require_relative "../../lib/format_success"

describe "Format Visits" do

  before(:each) do
  end

  after(:each) do
    FormatVisits.destroy!
  end

  before(:all) do
    Timecop.freeze(Time.utc(2012, 10, 10, 12, 0, 0))
  end

  after(:all) do
    Timecop.return
  end

  it "should be saved to db" do
    format_visit = FactoryGirl.build(:format_visits)

    format_visit.save

    FormatVisits.get(format_visit.id).should_not be_nil
  end

  describe "percent calculation" do
    it "should be 0.0 if entries are 0 and successes are 0" do
      format_visit = FactoryGirl.build(:format_visits, :entries => 0, :successes => 0)
      format_visit.percentage_of_success.should == 0.0
    end

    it "should be 100.0 if entries are 10 and successes are 10" do
      format_visit = FactoryGirl.build(:format_visits, :entries => 10, :successes => 10)
      format_visit.percentage_of_success.should == 100.0
    end

    it "should be 50.0 if entries are 10 and successes are 5" do
      format_visit = FactoryGirl.build(:format_visits, :entries => 10, :successes => 5)
      format_visit.percentage_of_success.should == 50.0
    end
  end

  describe "constraints" do
    it "should not have duplicated entries" do
      format = 'guide'
      sunday = Date.new(2012, 9, 9)
      saturday = sunday + 6

      FactoryGirl.create(:format_visits, format: format, start_at: sunday, end_at: saturday)

      lambda do
        format_visits = FactoryGirl.build(:format_visits, format: format, start_at: sunday, end_at: saturday)
        format_visits.save
      end.should raise_error
      end

    it "should not have different formats entries" do
      sunday = Date.new(2012, 9, 9)
      saturday = sunday + 6

      FactoryGirl.create(:format_visits, format: 'guide', start_at: sunday, end_at: saturday)

      lambda do
        format_visits = FactoryGirl.build(:format_visits, format: 'transaction', start_at: sunday, end_at: saturday)
        format_visits.save
      end.should_not raise_error
    end
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

  describe "get latest formats" do
    before(:all) do
      @first_sunday = Date.new(2012, 9, 9)
      @first_saturday = @first_sunday + 6
      @second_sunday = @first_sunday + 7
      @second_saturday = @second_sunday + 6
    end

    it "should get the data for the last collected week" do
      first = FactoryGirl.create(:format_visits, format: 'guide', start_at: @first_sunday, end_at: @first_saturday)
      second = FactoryGirl.create(:format_visits, format: 'guide', start_at: @second_sunday, end_at: @second_saturday)

      format_visits = FormatVisits.get_latest_formats
      format_visits.should include(second)
      format_visits.should_not include(first)
    end

    it "should get only one result per format" do
      guide = FactoryGirl.create(:format_visits, format: 'guide', start_at: @second_sunday, end_at: @second_saturday)
      transaction = FactoryGirl.create(:format_visits, format: 'transaction', start_at: @second_sunday, end_at: @second_saturday)
      whatever = FactoryGirl.create(:format_visits, format: 'whatever', start_at: @second_sunday, end_at: @second_saturday)

      format_visits = FormatVisits.get_latest_formats
      format_visits.should have(3).items
      format_visits.should include(guide, transaction, whatever)
    end

    it "should get only formats present for the latest week" do
      guide = FactoryGirl.create(:format_visits, format: 'guide', start_at: @first_sunday, end_at: @first_saturday)
      transaction = FactoryGirl.create(:format_visits, format: 'transaction', start_at: @second_sunday, end_at: @second_saturday)
      whatever = FactoryGirl.create(:format_visits, format: 'whatever', start_at: @second_sunday, end_at: @second_saturday)

      format_visits = FormatVisits.get_latest_formats
      format_visits.should have(2).items
      format_visits.should include(transaction, whatever)
    end
  end

  describe "should not allow future dates" do

    it "should not be valid with start_at in the future" do
      future_sunday = Date.new(2012, 10, 14)
      format_visits = FactoryGirl.create(:format_visits, format: 'guide', start_at: future_sunday, end_at: future_sunday + 6)

      format_visits.should_not be_valid
    end

    it "should not be valid with end_at in the future" do
      future_saturday = Date.new(2012, 10, 13)
      format_visits = FactoryGirl.create(:format_visits, format: 'guide', start_at: future_saturday - 6, end_at: future_saturday)

      format_visits.should_not be_valid
    end
  end
end
