class MonthlyLog
  include LogFile

  attr_reader :year, :month

  def initialize(year, month)
    @year = year.to_i
    @month = month.to_i
  end

  def daily_logs
    dir = Rails.configuration.bujo_data_path.join(year.to_s, format("%02d", month))
    return [] unless Dir.exist?(dir)

    Dir.glob(dir.join("[0-9][0-9].md")).sort.map do |path|
      day = File.basename(path, ".md").to_i
      DailyLog.new(Date.new(year, month, day))
    end
  end

  def file_path
    Rails.configuration.bujo_data_path.join(year.to_s, format("%02d", month), "monthly.md")
  end
end
