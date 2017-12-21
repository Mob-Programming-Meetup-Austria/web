require_relative '../all'

class AppModelsTestBase < TestBase

  def correct_path_format?(object)
    path = object.path
    ends_in_slash = path.end_with?('/')
    has_doubled_separator = path.scan('/' * 2).length != 0
    !ends_in_slash && !has_doubled_separator
  end

end
