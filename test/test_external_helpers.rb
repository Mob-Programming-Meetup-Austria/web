
module TestExternalHelpers # mix-in

  module_function

  def setup
    fail 'setup already called' unless @setup_called.nil?
    @setup_called = true
    @config = {}
    ENV.each { |key, value| @config[key] = value }
  end

  def teardown
    fail_if_setup_not_called('teardown')
    # set and no previous value -> unset
    (ENV.keys - @config.keys).each { |key| unset(key) }
    # set but has previous value -> restore
    (ENV.keys + @config.keys).each { |key| ENV[key] = @config[key] }
    @setup_called = nil
  end

  # - - - - - - - - - - - - - - - - - - -

  def unset_runner_class; unset_class('runner'); end
  def unset_storer_class; unset_class('storer'); end
  def unset_differ_class; unset_class('differ'); end
  def    unset_log_class; unset_class(   'log'); end

  def set_runner_class(value); set_class('runner', value); end
  def set_storer_class(value); set_class('storer', value); end
  def set_differ_class(value); set_class('differ', value); end
  def    set_log_class(value); set_class(   'log', value); end

  def get_runner_class; get_class('runner'); end
  def get_storer_class; get_class('storer'); end
  def get_differ_class; get_class('differ'); end
  def    get_log_class; get_class(   'log'); end

  # - - - - - - - - - - - - - - - - - - -

  def unset(var); ENV.delete(var); end

  def unset_class(name)
    unset(env_var.name(name + '_class'))
  end

  # - - - - - - - - - - - - - - - - - - -

  def set_class(key, value)
    fail_if_setup_not_called("set_class(#{key}, #{value})")
    ENV[env_var.name(key + '_class')] = value
  end

  # - - - - - - - - - - - - - - - - - - -

  def get_class(name)
    env_var.name(name + '_class')
  end

  def fail_if_setup_not_called(method)
    fail "#{method} NOT executed because setup() not yet called" if @setup_called.nil?
  end

end
