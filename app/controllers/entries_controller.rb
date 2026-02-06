class EntriesController < ApplicationController
  before_action :set_daily_log

  def create
    type = params[:entry_type] || "task"
    status = type == "task" ? :open : nil
    entry = Entry.new(type: type, status: status, text: params[:text])
    @daily_log.add_entry(entry)

    @entries = @daily_log.entries
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to daily_log_path(date: @date) }
    end
  end

  def update
    line_index = params[:line_index].to_i
    attrs = {}
    attrs[:status] = params[:status] if params[:status]
    attrs[:text] = params[:text] if params[:text]
    attrs[:type] = params[:type] if params[:type]
    @daily_log.update_entry(line_index, attrs)

    @entries = @daily_log.entries
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to daily_log_path(date: @date) }
    end
  end

  def migrate
    line_index = params[:line_index].to_i
    entry = @daily_log.entries.find { |e| e.line_index == line_index }

    if entry&.task? && entry.open?
      date = Date.parse(@date)
      monthly_log = MonthlyLog.new(date.year, date.month)
      monthly_log.add_entry(Entry.new(type: :task, status: :open, text: entry.text))
      @daily_log.update_entry(line_index, status: "migrated")
    end

    @entries = @daily_log.entries
    respond_to do |format|
      format.turbo_stream { render :update }
      format.html { redirect_to daily_log_path(date: @date) }
    end
  end

  def destroy
    @daily_log.remove_entry(params[:line_index].to_i)

    @entries = @daily_log.entries
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to daily_log_path(date: @date) }
    end
  end

  private

  def set_daily_log
    @date = params[:date]
    @daily_log = DailyLog.new(@date)
  end
end
