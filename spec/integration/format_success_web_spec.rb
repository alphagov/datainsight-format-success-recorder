require_relative "spec_helper"

describe("Format Success Web") do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it "should return the JSON data" do
    FactoryGirl.create(:format_visits, :format => 'guide')
    FactoryGirl.create(:format_visits, :format => 'smart_answer')

    get '/format-success'

    last_response.should be_ok
    response = JSON.parse(last_response.body)
    response.should have_key("id")
    response.should have_key("web_url")
    response.should have_key("updated_at")
    response["response_info"]["status"].should == "ok"

    data = response["details"]["data"]
    data.should be_an(Array)
    data.should include('format' => 'guide', 'entries' => 5000, 'percentage_of_success' => 80.0)
    data.should include('format' => 'smart_answer', 'entries' => 5000, 'percentage_of_success' => 80.0)
  end

  after(:each) do
    FormatVisits.destroy!
  end


end
