require_relative 'app_services_test_base'
require 'json'

class ZipperServiceTest < AppServicesTestBase

  def self.hex_prefix
    'D1279C'
  end

  def hex_setup
    set_differ_class('NotUsed')
    set_starter_class('NotUsed')
    set_storer_class('StorerFake')
    set_runner_class('NotUsed')
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test 'C16',
  'smoke test zipper.sha' do
    assert_sha zipper.sha
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test 'EBF',
  'smoke test zipper.zip' do
    error = assert_raises { zipper.zip(kata_id='') }
    assert_equal 'ServiceError', error.class.name
    assert_equal 'ZipperService', error.service_name
    assert_equal 'zip', error.method_name
    exception = JSON.parse(error.message)
    refute_nil exception
    assert_equal 'ServiceError', exception['class']
    json = JSON.parse(exception['message'])
    assert_equal 'ArgumentError', json['class']
    assert_equal 'kata_id:malformed', json['message']
    assert_equal 'Array', json['backtrace'].class.name
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '959',
  'smoke test zipper.zip_tag' do
    error = assert_raises { zipper.zip_tag(kata_id='', 'lion', 0) }
    assert_equal 'ServiceError', error.class.name
    assert_equal 'ZipperService', error.service_name
    assert_equal 'zip_tag', error.method_name
    exception = JSON.parse(error.message)
    refute_nil exception
    assert_equal 'ServiceError', exception['class']
    json = JSON.parse(exception['message'])
    assert_equal 'ArgumentError', json['class']
    assert_equal 'kata_id:malformed', json['message']
    assert_equal 'Array', json['backtrace'].class.name
  end

end
