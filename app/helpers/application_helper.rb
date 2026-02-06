module ApplicationHelper
  def date_entry_path(date, line_index)
    daily_entry_path(date: date.to_s, line_index: line_index)
  end

  def month_entry_path(year, month, line_index)
    monthly_entry_path(year: year, month: month, line_index: line_index)
  end
end
