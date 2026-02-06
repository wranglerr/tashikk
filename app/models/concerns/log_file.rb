module LogFile
  extend ActiveSupport::Concern

  def entries
    parse_entries(lines)
  end

  def add_entry(entry)
    ls = lines
    entry.line_index = ls.length
    ls.concat(entry.to_markdown.lines.map(&:chomp))
    write(ls)
    entry
  end

  def update_entry(line_index, attrs)
    ls = lines
    return nil if line_index >= ls.length

    entry = find_entry_at(ls, line_index)
    return nil unless entry

    entry.text = attrs[:text] if attrs[:text]
    entry.status = attrs[:status].to_sym if attrs[:status]
    entry.type = attrs[:type].to_sym if attrs[:type]
    entry.body = attrs[:body] if attrs.key?(:body)

    body_count = count_body_lines(ls, line_index)
    replacement = entry.to_markdown.lines.map(&:chomp)
    ls[line_index, 1 + body_count] = replacement
    write(ls)
    entry
  end

  def remove_entry(line_index)
    ls = lines
    return nil if line_index >= ls.length

    body_count = count_body_lines(ls, line_index)
    ls.slice!(line_index, 1 + body_count)
    write(ls)
  end

  private

  def parse_entries(ls)
    entries = []
    i = 0
    while i < ls.length
      entry = Entry.parse(ls[i], line_index: i)
      if entry
        if entry.snippet?
          body_lines = []
          while i + 1 < ls.length && ls[i + 1].start_with?("    ")
            i += 1
            body_lines << ls[i][4..]
          end
          entry.body = body_lines.join("\n") if body_lines.any?
        end
        entries << entry
      end
      i += 1
    end
    entries
  end

  def find_entry_at(ls, line_index)
    entry = Entry.parse(ls[line_index], line_index: line_index)
    return nil unless entry

    if entry.snippet?
      body_lines = []
      j = line_index + 1
      while j < ls.length && ls[j].start_with?("    ")
        body_lines << ls[j][4..]
        j += 1
      end
      entry.body = body_lines.join("\n") if body_lines.any?
    end
    entry
  end

  def count_body_lines(ls, line_index)
    count = 0
    j = line_index + 1
    while j < ls.length && ls[j].start_with?("    ")
      count += 1
      j += 1
    end
    count
  end

  def lines
    return [] unless File.exist?(file_path)
    File.read(file_path).lines.map(&:chomp)
  end

  def write(lines)
    FileUtils.mkdir_p(File.dirname(file_path))
    File.write(file_path, lines.join("\n") + "\n")
  end
end
