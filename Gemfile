source "https://rubygems.org"
source 'https://BnrJb6FZyzspBboNJzYZ@gem.fury.io/govuk/'

gem "rake", "0.9.2"
gem "data_mapper", "1.2.0"
gem "dm-mysql-adapter", "1.2.0"
gem "datainsight_logging", "0.0.3"
gem "airbrake", "3.1.5"
gem "datainsight_recorder", "0.3.1"

group :exposer do
  gem "unicorn"
  gem "sinatra"
end

group :recorder do
  gem "bunny"
  gem "gli", "1.6.0"
end

group :test do
  gem "dm-sqlite-adapter", "1.2.0"
  gem "rack-test"
  gem "rspec", "~> 2.11.0"
  gem "rspec-mocks", "~> 2.11.2"
  gem "ci_reporter"
  gem "factory_girl"
  gem "autotest"
  gem "timecop"
  gem "database_cleaner"
end

local_gemfile = File.dirname(__FILE__) + "/Gemfile.local.rb"
if File.file?(local_gemfile)
  self.instance_eval(Bundler.read_file(local_gemfile))
end
