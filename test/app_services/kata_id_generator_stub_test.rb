require_relative 'app_services_test_base'

class KataIdGeneratorStubTest < AppServicesTestBase

  def self.hex_prefix
    'EEDB7'
  end

  def hex_setup
    set_differ_class('NotUsed')
    set_storer_class('StorerFake')
    set_runner_class('NotUsed')
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '3E0',
  'generate when there are no stubs left raises' do
    id_generator.generate
    error = assert_raises { id_generator.generate }
    name = id_generator.class.name
    assert_equal "#{name}:out of stubs!", error.message
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '3E1',
  'by default, stub the test hex-id as the kata id' do
    assert_equal hex_test_kata_id, id_generator.generate
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '3E2',
  'stub() can set the stubbed kata id' do
    id_generator.stub( first_id = '8D616B84BF')
    assert_equal  first_id, id_generator.generate
    id_generator.stub(second_id = 'C175EEA250')
    assert_equal second_id, id_generator.generate
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3E3',
  'stub() with an invalid kata_id raises' do
    error = assert_raises(ArgumentError) {
      id_generator.stub(invalid_kata_id)
    }
    assert_equal 'invalid kata_id', error.message
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '3E5',
  'stub() with kata_id that already exists raises' do
    kata_id = storer.kata_create(make_manifest)
    error = assert_raises(ArgumentError) {
      id_generator.stub(kata_id)
    }
    assert_equal 'invalid kata_id', error.message
  end

  private

  def make_manifest
    manifest = starter.language_manifest('Ruby, MiniTest','Fizz_Buzz')
    manifest['created'] = creation_time
    manifest
  end

  def invalid_kata_id
    'sdfsdfsdf'
  end

end
