class MonthlyEntriesController < ApplicationController
  before_action :set_monthly_log

  def create
    type = params[:entry_type] || "task"
    status = type == "task" ? :open : nil
    body = type == "snippet" ? params[:body] : nil
    entry = Entry.new(type: type, status: status, text: params[:text], body: body)
    @monthly_log.add_entry(entry)

    @entries = @monthly_log.entries
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to monthly_log_path(year: @year, month: @month) }
    end
  end

  def update
    line_index = params[:line_index].to_i
    attrs = {}
    attrs[:status] = params[:status] if params[:status]
    attrs[:text] = params[:text] if params[:text]
    attrs[:type] = params[:type] if params[:type]
    attrs[:body] = params[:body] if params.key?(:body)
    @monthly_log.update_entry(line_index, attrs)

    @entries = @monthly_log.entries
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to monthly_log_path(year: @year, month: @month) }
    end
  end

  def destroy
    @monthly_log.remove_entry(params[:line_index].to_i)

    @entries = @monthly_log.entries
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to monthly_log_path(year: @year, month: @month) }
    end
  end

  private

  def set_monthly_log
    @year = params[:year].to_i
    @month = params[:month].to_i
    @monthly_log = MonthlyLog.new(@year, @month)
  end
end
