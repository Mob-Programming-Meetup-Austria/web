
module TestExternalHelpers # mix-in

  module_function

  include Externals

  def setup
    @config = {
      'CUSTOM'    => ENV['CYBER_DOJO_CUSTOM_CLASS'],
      'EXERCISES' => ENV['CYBER_DOJO_EXERCISES_CLASS'],
      'LANGUAGES' => ENV['CYBER_DOJO_LANGUAGES_CLASS'],
      'DIFFER'    => ENV['CYBER_DOJO_DIFFER_CLASS'],
      'RUNNER'    => ENV['CYBER_DOJO_RUNNER_CLASS'],
      'SAVER'     => ENV['CYBER_DOJO_SAVER_CLASS'],
      'ZIPPER'    => ENV['CYBER_DOJO_ZIPPER_CLASS'],
      'HTTP'      => ENV['CYBER_DOJO_HTTP_CLASS']
    }
  end

  def teardown
    ENV['CYBER_DOJO_CUSTOM_CLASS']    = @config['CUSTOM']
    ENV['CYBER_DOJO_EXERCISES_CLASS'] = @config['EXERCISES']
    ENV['CYBER_DOJO_LANGUAGES_CLASS'] = @config['LANGUAGES']
    ENV['CYBER_DOJO_DIFFER_CLASS']    = @config['DIFFER']
    ENV['CYBER_DOJO_RUNNER_CLASS']    = @config['RUNNER']
    ENV['CYBER_DOJO_SAVER_CLASS']     = @config['SAVER']
    ENV['CYBER_DOJO_ZIPPER_CLASS']    = @config['ZIPPER']
    ENV['CYBER_DOJO_HTTP_CLASS']      = @config['HTTP']
  end

  # - - - - - - - - - - - - - - - - - - -

  def set_differ_class(value)
    set_class('differ', value)
  end

  def set_runner_class(value)
    set_class('runner', value)
  end

  def set_saver_class(value)
    set_class('saver', value)
  end

  # - - - - - - - - - - - - - - - - - - -

  def set_class(name, value)
    key = 'CYBER_DOJO_' + name.upcase + '_CLASS'
    ENV[key] = value
  end

end
