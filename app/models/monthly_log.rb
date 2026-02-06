class MonthlyLog
  attr_reader :year, :month

  def initialize(year, month)
    @year = year.to_i
    @month = month.to_i
  end

  def entries
    lines.each_with_index.filter_map do |line, index|
      Entry.parse(line, line_index: index)
    end
  end

  def add_entry(entry)
    ls = lines
    entry.line_index = ls.length
    ls << entry.to_markdown
    write(ls)
    entry
  end

  def update_entry(line_index, attrs)
    ls = lines
    return nil if line_index >= ls.length

    entry = Entry.parse(ls[line_index], line_index: line_index)
    return nil unless entry

    entry.text = attrs[:text] if attrs[:text]
    entry.status = attrs[:status].to_sym if attrs[:status]
    entry.type = attrs[:type].to_sym if attrs[:type]
    ls[line_index] = entry.to_markdown
    write(ls)
    entry
  end

  def remove_entry(line_index)
    ls = lines
    return nil if line_index >= ls.length

    ls.delete_at(line_index)
    write(ls)
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

  private

  def lines
    return [] unless File.exist?(file_path)
    File.read(file_path).lines.map(&:chomp)
  end

  def write(lines)
    FileUtils.mkdir_p(File.dirname(file_path))
    File.write(file_path, lines.join("\n") + "\n")
  end
end
