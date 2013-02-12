require "json"
require "datainsight_recorder/recorder"
require_relative "model/format_success"
require_relative "model/content_engagement_visits"

module FormatSuccess
  class Recorder
    include DataInsight::Recorder::AMQP

    def queue_name
      "datainsight_format_success_recorder"
    end

    def routing_keys
      MODELS.keys
    end

    def update_message(message)
      routing_key = message[:envelope][:_routing_key]
      MODELS[routing_key].update_from_message(message)
    end

    private

    MODELS = {
        "google_analytics.entry_and_success.weekly" => FormatSuccess::Model,
          "google_analytics.content_engagement.weekly" => ContentEngagementVisits
    }
  end
end
