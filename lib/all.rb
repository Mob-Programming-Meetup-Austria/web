
# this list has order dependencies

%w{
  env_var
  name_of_caller
  externals
  nearest_ancestors

  time_now
  unique_id
  string_cleaner

  http
  http_spy
  log_spy
  log_stdout
}.each { |sourcefile| require_relative './' + sourcefile }
