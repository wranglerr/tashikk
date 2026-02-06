class DailyLogsController < ApplicationController
  def show
    @date = params[:date] ? Date.parse(params[:date]) : Date.today
    @daily_log = DailyLog.new(@date)
    @entries = @daily_log.entries

    if @date == Date.today && needs_review?
      redirect_to review_path and return
    end

    @prev_date = @date - 1
    @next_date = @date + 1
  end

  private

  def needs_review?
    return false if cookies[:last_review] == Date.today.to_s

    yesterday = DailyLog.new(Date.today - 1)
    yesterday.exists? && yesterday.open_tasks.any?
  end
end
