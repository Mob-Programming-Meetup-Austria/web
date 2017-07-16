require_relative 'app_lib_test_base'

class RunnerServiceTest < AppLibTestBase

  # These will fail if there is no network connectivity.

  def setup
    super
    #set_storer_class('StorerThrower')
    set_runner_class('RunnerService')
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_stateful_runner(kata_id, image_name)
    @http = HttpSpy.new(nil)
    args = []
    args << (stateful = true)
    args << image_name
    args << kata_id
    args << (avatar_name = lion)
    args << (max_seconds = 10)
    args << (delta = { :deleted => [], :new => [],:changed => {} })
    args << (files = {})
    runner.run(*args)
    assert @http.spied_hostname? 'runner'
    assert @http.spied_named_arg? :deleted_filenames
    assert @http.spied_named_arg? :changed_files
    refute @http.spied_named_arg? :visible_files
  end

  test '2BDF80874C',
  'stateful run() delegates to stateful runner',
  'args include deleted_filenames and changed_files' do
    assert_stateful_runner('2BDAD8074C', 'cyberdojofoundation/gcc_assert')
    assert_stateful_runner('2BDAD8074D', 'quay.io:8080/cyberdojofoundation/gcc_assert:latest')
    assert_stateful_runner('2BDAD8074E', 'localhost/cyberdojofoundation/gcc_assert:stateless')
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_stateless_runner(kata_id, image_name)
    @http = HttpSpy.new(nil)
    args = []
    args << (stateful = false)
    args << image_name
    args << kata_id
    args << (avatar_name = lion)
    args << (max_seconds = 10)
    args << (delta = { :deleted => [], :new => [],:changed => {} })
    args << (files = {})
    runner.run(*args)
    assert @http.spied_hostname? 'runner_stateless'
    refute @http.spied_named_arg? :deleted_filenames
    refute @http.spied_named_arg? :changed_files
    assert @http.spied_named_arg? :visible_files
  end

  test '2BDF808601',
  'stateless run() delegates to stateless runner',
  'args do not include deleted_filenames or changed_files',
  'but do include visible_files' do
    assert_stateless_runner('2BDAD80601', 'cyberdojofoundation/gcc_assert_stateless')
    assert_stateless_runner('2BDAD80602', 'quay.io:8080/cyberdojofoundation/gcc_assert_stateless')
    assert_stateless_runner('2BDAD80603', 'localhost/cyberdojofoundation/gcc_assert_stateless:1.2')
  end

end
