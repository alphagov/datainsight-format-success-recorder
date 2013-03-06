class Artefact
  include DataMapper::Resource
  include DataInsight::Recorder::BaseFields

  property :format, String, required: true
  property :title, String, length: 255, required: true
  property :url, String, length: 255, required: true
  property :slug, String, length: 255, required: true

  def self.update_from_message(message)
    values = {
        collected_at: DateTime.parse(message[:envelope][:collected_at]),
        source: message[:envelope][:collector],
        format: fix_format(message[:payload][:format]),
        title: message[:payload][:title],
        url: message[:payload][:web_url],
        slug: message[:payload][:web_url].split("/").last
    }

    query = {
        format: values[:format],
        slug: values[:slug]
    }

    artefact = Artefact.first(query)
    if artefact
      logger.info("Update existing record for #{query}")
      artefact.update(values)
    else
      logger.info("Create new record for #{query}")
      Artefact.create(values)
    end
  end

  private
  def self.fix_format(format)
    case format
    when "smart-answer"
      "smart_answer"
    else
      format
    end
  end
end