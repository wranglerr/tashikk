class DailyLog
  include LogFile

  attr_reader :date

  def initialize(date)
    @date = date.is_a?(String) ? Date.parse(date) : date
  end

  def open_tasks
    entries.select(&:open?)
  end

  def exists?
    File.exist?(file_path)
  end

  def file_path
    dir = Rails.configuration.bujo_data_path.join(date.year.to_s, format("%02d", date.month))
    dir.join("#{format("%02d", date.day)}.md")
  end
end
