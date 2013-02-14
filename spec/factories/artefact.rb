require_relative "../../lib/datamapper_config"

FactoryGirl.define do
  factory :artefact do
    source "default source"
    collected_at DateTime.new(1970, 1, 1, 0, 0, 0)
    format "default-format"
    title "Default title"
    url "http://default-url"
    slug "default-slug"
  end
end