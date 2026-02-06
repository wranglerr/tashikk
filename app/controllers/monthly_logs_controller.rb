class MonthlyLogsController < ApplicationController
  def show
    @year = params[:year].to_i
    @month = params[:month].to_i
    @monthly_log = MonthlyLog.new(@year, @month)
    @entries = @monthly_log.entries
    @daily_logs = @monthly_log.daily_logs

    @month_date = Date.new(@year, @month, 1)
    @prev_month = @month_date.prev_month
    @next_month = @month_date.next_month
  end
end
