require 'dm-constraints'
require 'dm-migrations'
require 'datainsight_logging'

require_relative '../lib/model/format_success'
require_relative '../lib/model/content_engagement_visits'
require_relative '../lib/model/artefact'

module DataMapperConfig
  def self.configure(env=ENV["RACK_ENV"])
    DataMapper.logger = Logging.logger[DataMapper]
    case (env or "default").to_sym
    when :test
      DataMapperConfig.configure_test
    when :production
      DataMapperConfig.configure_production
    else
      DataMapperConfig.configure_development
    end
    DataMapper::Model.raise_on_save_failure = true
  end

  private

  def self.configure_development
    configure_db('mysql://root:@localhost/datainsights_format_success')
  end

  def self.configure_production
    configure_db('mysql://datainsight:@localhost/datainsights_format_success')
  end

  def self.configure_test
    configure_db('mysql://datainsight:@localhost/datainsights_format_success_test')
  end

  def self.configure_db(connection_url)
    DataMapper.setup(:default, connection_url)
    DataMapper.finalize
  end

end
