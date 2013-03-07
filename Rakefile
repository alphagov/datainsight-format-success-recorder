require 'rubygems'
require 'rspec/core/rake_task'
require 'ci/reporter/rake/rspec'

task :default => :spec

RSpec::Core::RakeTask.new do |task|
  task.pattern = 'spec/**/*_spec.rb'
  task.rspec_opts = ["--format documentation"]
end

namespace :spec do
  desc "Run RSpec unit code examples"
  RSpec::Core::RakeTask.new (:model) do |task|
    task.pattern = "spec/unit/*_spec.rb"
    task.rspec_opts = ["--format documentation"]
  end

  desc "Run RSpec functional code examples"
  RSpec::Core::RakeTask.new(:functional) do |task|
    task.pattern = "spec/functional/*_spec.rb"
    task.rspec_opts = ["--format documentation"]
  end
end

require_relative "lib/datamapper_config"
namespace :db do
  task :configure do
    DataMapperConfig.configure
  end

  namespace :migrate do

    desc "Run all pending migrations"
    task :up => :load_migrations do
      migrate_up!
    end

    desc "Rollback last migration"
    task :down => :load_migrations do
      migration = DataMapper.migrations.sort.reverse.find { |migration| migration.needs_down? }
      migration.perform_down
    end

    desc "Show current status of migrations"
    task :status => :load_migrations do
      puts "Status of migrations on schema #{DataMapper.repository.adapter.schema_name}"

      DataMapper.migrations.sort.each do |migration|
        puts "#{migration.needs_down? ? '   UP' : ' DOWN'} : #{migration.position}. #{migration.name}"
      end
    end

    task :load_migrations => "db:configure" do
      require 'dm-migrations/migration_runner'
      FileList['db/migrate/*.rb'].each do |migration|
        load migration
      end
    end
  end
end
