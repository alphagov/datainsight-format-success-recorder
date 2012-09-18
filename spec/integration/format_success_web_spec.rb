require_relative "spec_helper"

describe("Format Success Web") do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  after(:each) do

  end


end
