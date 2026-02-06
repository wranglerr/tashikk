class ReviewsController < ApplicationController
  def show
    @yesterday = Date.today - 1
    @yesterday_log = DailyLog.new(@yesterday)
    @open_tasks = @yesterday_log.open_tasks

    if @open_tasks.empty?
      cookies[:last_review] = Date.today.to_s
      redirect_to root_path
    end
  end

  def process_review
    yesterday = Date.today - 1
    yesterday_log = DailyLog.new(yesterday)
    today_log = DailyLog.new(Date.today)
    monthly_log = MonthlyLog.new(Date.today.year, Date.today.month)

    decisions = params[:decisions] || {}

    # Process in reverse order so line indices stay valid
    decisions.keys.map(&:to_i).sort.reverse_each do |line_index|
      decision = decisions[line_index.to_s]
      entry = yesterday_log.entries.find { |e| e.line_index == line_index }
      next unless entry

      case decision
      when "migrate_today"
        yesterday_log.update_entry(line_index, status: "migrated")
        today_log.add_entry(Entry.new(type: :task, status: :open, text: entry.text))
      when "migrate_monthly"
        yesterday_log.update_entry(line_index, status: "migrated")
        monthly_log.add_entry(Entry.new(type: :task, status: :open, text: entry.text))
      when "complete"
        yesterday_log.update_entry(line_index, status: "done")
      when "cancel"
        yesterday_log.update_entry(line_index, status: "canceled")
      when "keep"
        # Leave as-is
      end
    end

    cookies[:last_review] = Date.today.to_s
    redirect_to root_path
  end
end
