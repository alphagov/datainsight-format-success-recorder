require_relative '../../spec/spec_helper'

describe "Format Success" do

  class FormatVisitsDummy
    def initialize format_label
      @format_label = format_label
      @entries = 100
      @percentage_of_success = 50.0
    end
    attr_reader :format_label, :entries, :percentage_of_success
  end

  before(:each) do
    @guide = FormatVisitsDummy.new("Guide")
    @transaction = FormatVisitsDummy.new("Transaction")
    @smart_answer = FormatVisitsDummy.new("Smart Answer")
  end

  it "should create a entry/success data for the graph" do
    FormatVisits.stub(:get_latest_formats).and_return([@guide, @transaction, @smart_answer])

    entry_success_data = FormatSuccess.new.format_success

    entry_success_data.should be_an(Array)
    entry_success_data.should have(3).items
    entry_success_data.should include({:format => 'Guide', :entries => 100, :percentage_of_success => 50.0})
    entry_success_data.should include({:format => 'Transaction', :entries => 100, :percentage_of_success => 50.0})
    entry_success_data.should include({:format => 'Smart Answer', :entries => 100, :percentage_of_success => 50.0})
  end

end