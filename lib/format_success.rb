class FormatSuccess
  def format_success
    format_visits = "some fancy query"

    format_visits.map { |each|
      {
        :total_visits => each.total_visits,
        :percentage_of_success => each.percentage_of_success
      }
    }
  end
end
