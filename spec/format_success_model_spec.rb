require "date"

require_relative "spec_helper"

describe "Format Visits" do

  before(:each) do
  end

  after(:each) do
    FormatSuccess::Model.destroy!
  end

  before(:all) do
    Timecop.freeze(Time.utc(2012, 10, 10, 12, 0, 0))
  end

  after(:all) do
    Timecop.return
  end

  describe "update from message" do
    before(:each) do
      @message = {
        :envelope => {
          :collected_at => "2012-12-12T00:00:00",
          :collector    => "Google Analytics",
          :_routing_key => "google_analytics.entry_and_success.weekly"
        },
        :payload => {
          :start_at => "2011-03-28T00:00:00+01:00",
          :end_at => "2011-04-04T00:00:00+01:00",
          :value => {
            :site => "govuk",
            :format => "transaction",
            :entries => 10792,
            :successes => 0
          }
        }
      }
    end

    it "should insert a new record" do
      FormatSuccess::Model.update_from_message(@message)

      records = FormatSuccess::Model.all

      records.should have(1).item

      record = records.first
      record.collected_at.should == DateTime.new(2012, 12, 12)
      record.start_at.should == DateTime.parse("2011-03-28T00:00:00+01:00")
      record.end_at.should == DateTime.parse("2011-04-04T00:00:00+01:00")
      record.format.should == "transaction"
      record.entries.should == 10792
      record.successes.should == 0
    end

    it "should update an existing record" do
      FormatSuccess::Model.update_from_message(@message)
      @message[:payload][:value][:entries] = 9
      @message[:payload][:value][:successes] = 1
      FormatSuccess::Model.update_from_message(@message)

      records = FormatSuccess::Model.all

      records.should have(1).item

      record = records.first
      record.collected_at.should == DateTime.new(2012, 12, 12)
      record.start_at.should == DateTime.parse("2011-03-28T00:00:00+01:00")
      record.end_at.should == DateTime.parse("2011-04-04T00:00:00+01:00")
      record.format.should == "transaction"
      record.entries.should == 9
      record.successes.should == 1
    end

  end

  it "should be saved to db" do
    format_success = FactoryGirl.build(:format_success)

    format_success.valid?
    format_success.errors.each { |e| p e }
    format_success.save

    FormatSuccess::Model.get(format_success.id).should_not be_nil
  end

  describe "percent calculation" do
    it "should be 0.0 if entries are 0 and successes are 0" do
      format_success = FactoryGirl.build(:format_success, :entries => 0, :successes => 0)
      format_success.percentage_of_success.should == 0.0
    end

    it "should be 100.0 if entries are 10 and successes are 10" do
      format_success = FactoryGirl.build(:format_success, :entries => 10, :successes => 10)
      format_success.percentage_of_success.should == 100.0
    end

    it "should be 50.0 if entries are 10 and successes are 5" do
      format_success = FactoryGirl.build(:format_success, :entries => 10, :successes => 5)
      format_success.percentage_of_success.should == 50.0
    end
  end

  describe "constraints" do
    it "should not have duplicated entries" do
      format = 'guide'
      sunday = DateTime.new(2012, 9, 9)
      next_sunday = sunday + 7

      FactoryGirl.create(:format_success, format: format, start_at: sunday, end_at: next_sunday)

      lambda do
        format_success = FactoryGirl.build(:format_success, format: format, start_at: sunday, end_at: next_sunday)
        format_success.save
      end.should raise_error
    end

    it "should not have different format entries" do
      sunday = DateTime.new(2012, 9, 9)
      next_sunday = sunday + 7

      FactoryGirl.create(:format_success, format: 'guide', start_at: sunday, end_at: next_sunday)

      lambda do
        format_success = FactoryGirl.build(:format_success, format: 'transaction', start_at: sunday, end_at: next_sunday)
        format_success.save
      end.should_not raise_error
    end
  end

  describe "validations" do
    it "should be valid" do
      format_success = FactoryGirl.build(:format_success)

      format_success.should be_valid
    end

    it "should not be valid if collected at is nil" do
      format_success = FactoryGirl.build(:format_success, :collected_at => nil)

      format_success.should_not be_valid
    end

    describe "start and end date" do
      it "should not be valid if start at is nil" do
        format_success = FactoryGirl.build(:format_success, :start_at => nil)

        format_success.should_not be_valid
      end

      it "should not be valid if end at is nil" do
        format_success = FactoryGirl.build(:format_success, :end_at => nil)

        format_success.should_not be_valid
      end

      it "should be valid if date range is a week" do
        format_success = FactoryGirl.build(:format_success,
                                         :start_at => DateTime.new(2012, 9, 16),
                                         :end_at => DateTime.new(2012, 9, 23))

        format_success.should be_valid
      end

      it "should not be valid if date range is only 6 days" do
        format_success = FactoryGirl.build(:format_success,
                                         :start_at => DateTime.new(2012, 9, 16),
                                         :end_at => DateTime.new(2012, 9, 22))

        format_success.should_not be_valid
      end

      it "should not be valid if date range is 8 days" do
        format_success = FactoryGirl.build(:format_success,
                                         :start_at => DateTime.new(2012, 9, 16),
                                         :end_at => DateTime.new(2012, 9, 24))

        format_success.should_not be_valid
      end

      it "should not be valid if start at is a monday" do
        format_success = FactoryGirl.build(:format_success,
                                         :start_at => DateTime.new(2012, 9, 17),
                                         :end_at => DateTime.new(2012, 9, 23))

        format_success.should_not be_valid
      end
    end

    describe "entries" do

      it "should not be valid if not present" do
        format_success = FactoryGirl.build(:format_success, :entries => nil)

        format_success.should_not be_valid
      end

      it "should not be valid if is not integer" do
        format_success = FactoryGirl.build(:format_success, :entries => "no_integer")

        format_success.should_not be_valid
      end

      it "should not be valid if negative" do
        format_success = FactoryGirl.build(:format_success, :entries => -1)

        format_success.should_not be_valid
      end

      it "should be valid if zero" do
        format_success = FactoryGirl.build(:format_success, :entries => 0, :successes => 0)

        format_success.should be_valid
      end

    end

    describe "successes" do

      it "should not be valid if not present" do
        format_success = FactoryGirl.build(:format_success, :successes => nil)

        format_success.should_not be_valid
      end

      it "should not be valid if is not integer" do
        format_success = FactoryGirl.build(:format_success, :successes => "no_integer")

        format_success.should_not be_valid
      end

      it "should not be valid if negative" do
        format_success = FactoryGirl.build(:format_success, :successes => -1)

        format_success.should_not be_valid
      end

      it "should not be valid if equal to entries" do
        format_success = FactoryGirl.build(:format_success, :entries => 10, :successes => 10)

        format_success.should be_valid
      end

      it "should not be valid if bigger than entries" do
        format_success = FactoryGirl.build(:format_success, :entries => 10, :successes => 20)

        format_success.should_not be_valid
      end

      it "should be valid if zero" do
        format_success = FactoryGirl.build(:format_success, :successes => 0)

        format_success.should be_valid
      end
    end

  end

  describe "get latest formats" do
    before(:all) do
      @first_sunday = Date.new(2012, 9, 9)
      @second_sunday = @first_sunday + 7
      @third_sunday = @second_sunday + 7
    end

    it "should get the data for the last collected week" do
      first = FactoryGirl.create(:format_success, format: 'guide', start_at: @first_sunday, end_at: @second_sunday)
      second = FactoryGirl.create(:format_success, format: 'guide', start_at: @second_sunday, end_at: @third_sunday)

      format_success = FormatSuccess::Model.get_latest_formats
      format_success.should include(second)
      format_success.should_not include(first)
    end

    it "should get only one result per format" do
      guide = FactoryGirl.create(:format_success, format: 'guide', start_at: @second_sunday, end_at: @third_sunday)
      transaction = FactoryGirl.create(:format_success, format: 'transaction', start_at: @second_sunday, end_at: @third_sunday)
      whatever = FactoryGirl.create(:format_success, format: 'whatever', start_at: @second_sunday, end_at: @third_sunday)

      format_success = FormatSuccess::Model.get_latest_formats
      format_success.should have(3).items
      format_success.should include(guide, transaction, whatever)
    end

    it "should get only formats present for the latest week" do
      FactoryGirl.create(:format_success, format: 'guide', start_at: @first_sunday, end_at: @second_sunday)
      transaction = FactoryGirl.create(:format_success, format: 'transaction', start_at: @second_sunday, end_at: @third_sunday)
      whatever = FactoryGirl.create(:format_success, format: 'whatever', start_at: @second_sunday, end_at: @third_sunday)

      format_success = FormatSuccess::Model.get_latest_formats
      format_success.should have(2).items
      format_success.should include(transaction, whatever)
    end

    it "should get only formats in the filter list if provided" do
      transaction = FactoryGirl.create(:format_success, format: 'transaction', start_at: @second_sunday, end_at: @third_sunday)
      FactoryGirl.create(:format_success, format: 'whatever', start_at: @second_sunday, end_at: @third_sunday)

      format_success = FormatSuccess::Model.get_latest_formats(%w(transaction))
      format_success.should have(1).items
      format_success.should include(transaction)
    end
  end

  describe "should not allow future dates" do

    it "should not be valid with start_at in the future" do
      future_sunday = DateTime.new(2012, 10, 14)
      format_success = FactoryGirl.create(:format_success, format: 'guide', start_at: future_sunday, end_at: future_sunday + 7)

      format_success.should_not be_valid
    end

  end
end
