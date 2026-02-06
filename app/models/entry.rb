class Entry
  TYPES = %i[task note event snippet].freeze
  STATUSES = %i[open done canceled migrated].freeze

  SIGNIFIERS = {
    ["task", "open"]      => "- [ ] ",
    ["task", "done"]      => "- [x] ",
    ["task", "canceled"]  => "- [~] ",
    ["task", "migrated"]  => "- [>] ",
    ["note", nil]         => "- ",
    ["event", nil]        => "- [o] ",
    ["snippet", nil]      => "- [s] ",
  }.freeze

  PARSE_PATTERNS = [
    { pattern: /\A- \[x\] (.+)\z/, type: :task, status: :done },
    { pattern: /\A- \[~\] (.+)\z/, type: :task, status: :canceled },
    { pattern: /\A- \[>\] (.+)\z/, type: :task, status: :migrated },
    { pattern: /\A- \[ \] (.+)\z/, type: :task, status: :open },
    { pattern: /\A- \[o\] (.+)\z/, type: :event, status: nil },
    { pattern: /\A- \[s\] (.+)\z/, type: :snippet, status: nil },
    { pattern: /\A- (.+)\z/,       type: :note, status: nil },
  ].freeze

  attr_accessor :type, :status, :text, :body, :line_index

  def initialize(type:, text:, status: nil, body: nil, line_index: nil)
    @type = type.to_sym
    @status = status&.to_sym
    @text = text
    @body = body
    @line_index = line_index
  end

  def self.parse(line, line_index:)
    PARSE_PATTERNS.each do |spec|
      if (match = line.match(spec[:pattern]))
        return new(type: spec[:type], status: spec[:status], text: match[1], line_index: line_index)
      end
    end
    nil
  end

  def to_markdown
    key = [type.to_s, status&.to_s]
    prefix = SIGNIFIERS[key] || "- "
    header = "#{prefix}#{text}"
    return header unless snippet? && body.present?

    body_lines = body.lines.map { |l| "    #{l.chomp}" }
    [header, *body_lines].join("\n")
  end

  def task? = type == :task
  def note? = type == :note
  def event? = type == :event
  def snippet? = type == :snippet
  def open? = status == :open
  def done? = status == :done
  def canceled? = status == :canceled
  def migrated? = status == :migrated

  def marker
    case [type, status]
    when [:task, :open]     then " "
    when [:task, :done]     then "x"
    when [:task, :canceled] then "~"
    when [:task, :migrated] then ">"
    when [:event, nil]      then "o"
    when [:snippet, nil]    then "s"
    else nil
    end
  end

  def next_status
    case status
    when :open then :done
    when :done then :canceled
    when :canceled then :open
    else status
    end
  end
end
