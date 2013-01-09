require 'dm-constraints'
require 'dm-migrations'

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
    DataMapper.setup(:default, 'mysql://datainsight:@localhost/datainsights_format_success')
    DataMapper.finalize
    DataMapper.auto_upgrade!
  end

  def self.configure_production
    DataMapper.setup(:default, 'mysql://datainsight:@localhost/datainsights_format_success')
    DataMapper.finalize
    DataMapper.auto_upgrade!
  end

  def self.configure_test
    DataMapper.setup(:default, 'mysql://datainsight:@localhost/datainsights_format_success_test')
    DataMapper.finalize
    DataMapper.auto_upgrade!
  end
end
