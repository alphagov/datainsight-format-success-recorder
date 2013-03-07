require "data_mapper"
require "dm-migrations/migration_runner"

module DataMapper
  module Migrations
    module MysqlAdapter

      def index_exists?(name, table)
        statement = "show index from #{quote_name(table)} where key_name = ?"
        select(statement, name).count > 0
      end
    end
  end
end

migration 1, :create_initial_schema do
  up do
    unless adapter.storage_exists?("artefacts")
      create_table :artefacts do
        column :id, "INTEGER(10) UNSIGNED AUTO_INCREMENT PRIMARY KEY" # Integer, serial: true
        column :collected_at, DateTime, allow_nil: false
        column :source, String, allow_nil: false
        column :format, String, allow_nil: false
        column :title, String, length: 255, allow_nil: false
        column :url, String, length: 255, allow_nil: false
        column :slug, String, length: 255, allow_nil: false
      end
    end

    unless adapter.storage_exists?("content_engagement_visits")
      create_table :content_engagement_visits do
        column :id, "INTEGER(10) UNSIGNED AUTO_INCREMENT PRIMARY KEY" # Integer, serial: true
        column :collected_at, DateTime, allow_nil: false
        column :source, String, allow_nil: false
        column :start_at, DateTime, allow_nil: false
        column :end_at, DateTime, allow_nil: false
        column :format, String, allow_nil: false
        column :slug, DataMapper::Property::Text, allow_nil: false
        column :entries, Integer, allow_nil: false
        column :successes, Integer, allow_nil: false
      end
    end

    unless adapter.storage_exists?("format_success_models")
      create_table :format_success_models do
        column :id, "INTEGER(10) UNSIGNED AUTO_INCREMENT PRIMARY KEY" # Integer, serial: true
        column :collected_at, DateTime, allow_nil: false
        column :source, String, allow_nil: false
        column :start_at, DateTime, allow_nil: false
        column :end_at, DateTime, allow_nil: false
        column :entries, Integer, allow_nil: false
        column :successes, Integer, allow_nil: false
        column :format, String, allow_nil: false
      end
    end

    unless adapter.index_exists?("unique_format_success_models_format_date_range", "format_success_models")
      create_index :format_success_models, :start_at, :end_at, :format, unique: true, name: "unique_format_success_models_format_date_range"
    end
  end

  down do
    drop_table :artefacts
    drop_table :content_engagement_visits
    drop_table :format_success_models
  end
end
