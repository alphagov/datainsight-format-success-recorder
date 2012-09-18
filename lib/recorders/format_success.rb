require 'json'

require_relative '../model/format_visits'

module Recorders
  class FormatSuccessRecorder

    def run
      queue.subscribe do |msg|
        begin
          logger.debug { "Received a message: #{msg}" }
          process_message(JSON.parse(msg[:payload], :symbolize_names => true))
        rescue Exception => e
          logger.error { e }
        end
      end
    end

    private
    def queue
      @queue ||= create_queue
    end

    def create_queue
      client = Bunny.new ENV['AMQP']
      client.start
      queue = client.queue(ENV['QUEUE'] || 'format_success')
      exchange = client.exchange('datainsight', :type => :topic)

      queue.bind(exchange, :key => 'google_analytics.entry_and_success.weekly')
      logger.info("Bound to google_analytics.entry_and_success.weekly, listening for events")
      queue
    end

    def process_message(message)
      logger.debug { "Processing: #{message}" }

      identifying_key = {
          :start_at => parse_start_at(message[:payload][:start_at]),
          :end_at => parse_end_at(message[:payload][:end_at]),
          :format => message[:payload][:format]
      }

      data = {
          :collected_at => DateTime.parse(message[:envelope][:collected_at]),
          :entries => message[:payload][:entries],
          :successes => message[:payload][:successes]
      }

      format_visits = FormatVisits.first(identifying_key)
      if format_visits
        format_visits.update(data)
      else
        FormatVisits.create(identifying_key.merge(data))
      end
    end

    def parse_start_at(start_at)
      DateTime.parse(start_at)
    end

    # This recorder stores start and end as dates while the message format uses date times on date boundaries (midnight).
    # This means that the date may have to be shifted back
    def parse_end_at(end_at)
      end_at = DateTime.parse(end_at)
      if (end_at.hour + end_at.minute + end_at.second) == 0
        # up to midnight, so including the previous day
        end_at - 1
      else
        end_at
      end
    end
  end
end
