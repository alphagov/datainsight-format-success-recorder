require 'json'

require_relative '../model/format_visits'

module Recorders
  class FormatSuccessRecorder

    def initialize
      client = Bunny.new ENV['AMQP']
      client.start
      @queue = client.queue(ENV['QUEUE'] || 'format_success')
      exchange = client.exchange('datainsight', :type => :topic)

      @queue.bind(exchange, :key => 'google_analytics.format_success.weekly')
      logger.info("Bound to google_analytics.format_success.weekly, listening for events")
    end

    def run
      @queue.subscribe do |msg|
        begin
          logger.debug { "Received a message: #{msg}" }
          FormatSuccessRecorder.process_message(JSON.parse(msg[:payload], :symbolize_names => true))
        rescue Exception => e
          logger.error { e }
        end
      end
    end

    def self.process_message(message)
      #validate_message_value(message)
      #format_success = FormatSuccess.first(
      #    :start_at => DateTime.parse(message[:payload][:start_at]),
      #    :end_at => DateTime.parse(message[:payload][:end_at]),
      #    :format => message[:payload][:format]
      #)
      #if format_success
      #  format_success.update(
      #      collected_at: message[:envelope][:collected_at],
      #      total_visits: message[:payload][:total_visits],
      #      successful_visits: message[:payload][:total_visits]
      #  )
      #else
      #  FormatSuccess.create(
      #      :collected_at => DateTime.parse(message[:envelope][:collected_at]),
      #      :start_at => DateTime.parse(message[:payload][:start_at]),
      #      :end_at => DateTime.parse(message[:payload][:end_at]),
      #      :format => message[:payload][:format],
      #      :value => message[:payload][:value]
      #  )
      #end
    end

    #private
    #def self.validate_message_value(message)
    #  raise "No value provided in message payload: #{message.inspect}" unless message[:payload].has_key? :value
    #  raise "Invalid value provided in message payload: #{message.inspect}" unless message[:payload][:value].is_a? Integer
    #end
  end
end
