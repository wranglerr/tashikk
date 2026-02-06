Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "daily_logs#show"

  get  "daily/:date", to: "daily_logs#show", as: :daily_log, constraints: { date: /\d{4}-\d{2}-\d{2}/ }
  post   "daily/:date/entries",             to: "entries#create",  as: :daily_entries
  patch  "daily/:date/entries/:line_index", to: "entries#update",  as: :daily_entry
  post   "daily/:date/entries/:line_index/migrate", to: "entries#migrate", as: :migrate_daily_entry
  delete "daily/:date/entries/:line_index", to: "entries#destroy"

  get  "monthly/:year/:month", to: "monthly_logs#show", as: :monthly_log
  post  "monthly/:year/:month/entries",             to: "monthly_entries#create",  as: :monthly_entries
  patch "monthly/:year/:month/entries/:line_index", to: "monthly_entries#update",  as: :monthly_entry
  delete "monthly/:year/:month/entries/:line_index", to: "monthly_entries#destroy"

  get  "review",         to: "reviews#show",    as: :review
  post "review/process", to: "reviews#process", as: :process_review
end
