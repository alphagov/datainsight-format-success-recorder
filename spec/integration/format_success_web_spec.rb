require_relative "spec_helper"

describe("Format Success Web") do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it "should return the JSON data" do
    FactoryGirl.create(:format_visits, :format => 'guide')
    FactoryGirl.create(:format_visits, :format => 'transaction')

    get '/format-success'

    last_response.should be_ok
    response = JSON.parse(last_response.body)

    response.should be_an(Array)
    response.should include('format' => 'Guide', 'entries' => 5000, 'percentage_of_success' => 80.0)
    response.should include('format' => 'Transaction', 'entries' => 5000, 'percentage_of_success' => 80.0)
  end

  after(:each) do
    FormatVisits.destroy!
  end


end
