class FormatSuccess

  def format_success formats
    format_visits = FormatVisits.get_latest_formats

    format_visits.
      select { |format_visit| formats.include?(format_visit.format) }.
      map { |format_visit|
        {
            :format => formats[format_visit.format],
            :entries => format_visit.entries,
            :percentage_of_success => format_visit.percentage_of_success
        }
      }
  end
end
