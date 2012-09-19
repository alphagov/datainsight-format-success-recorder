class FormatSuccess
  def format_success
    format_visits = FormatVisits.get_latest_formats

    format_visits.map { |format_visit|
      {
          :format => format_visit.format_label,
          :entries => format_visit.entries,
          :percentage_of_success => format_visit.percentage_of_success
      }
    }
  end
end
