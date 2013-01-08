require "json"
require "datainsight_recorder/recorder"
require_relative "model"

module Recorders
  class FormatSuccessRecorder
    include DataInsight::Recorder::AMQP

    def queue_name
      "datainsight_format_success_recorder"
    end

    def routing_keys
      ["google_analytics.entry_and_success.weekly"]
    end

    def update_message(message)
      FormatSuccess::Model.update_from_message(message)
    end
  end
end
