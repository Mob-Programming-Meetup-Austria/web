require_relative 'app_models_test_base'

class ExternalDouble
  def initialize(_root)
  end
end

class ExternalsTest < AppModelsTestBase

  def self.hex_prefix
    'A1E2DC'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test '880',
  'setting an external class to the name of an existing class succeeds' do
    exists = 'ExternalDouble'
    set_differ_class(exists)  && assert_equal(exists, differ.class.name)
    set_runner_class(exists)  && assert_equal(exists, runner.class.name)
    set_starter_class(exists) && assert_equal(exists, starter.class.name)
    set_storer_class(exists)  && assert_equal(exists, storer.class.name)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test '881',
  'setting an external class to the name of a non-existant class raises StandardError' do
    error = StandardError
    does_not_exist = 'DoesNotExist'
    set_differ_class(does_not_exist)  && assert_raises(error) { differ.class  }
    set_runner_class(does_not_exist)  && assert_raises(error) { runner.class  }
    set_starter_class(does_not_exist) && assert_raises(error) { starter.class }
    set_storer_class(does_not_exist)  && assert_raises(error) { storer.class  }
  end

end
