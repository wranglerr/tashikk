class DailyLog
  attr_reader :date

  def initialize(date)
    @date = date.is_a?(String) ? Date.parse(date) : date
  end

  def entries
    lines.each_with_index.filter_map do |line, index|
      Entry.parse(line, line_index: index)
    end
  end

  def open_tasks
    entries.select(&:open?)
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

  def exists?
    File.exist?(file_path)
  end

  def file_path
    dir = Rails.configuration.bujo_data_path.join(date.year.to_s, format("%02d", date.month))
    dir.join("#{format("%02d", date.day)}.md")
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
