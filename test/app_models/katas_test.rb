require_relative 'app_models_test_base'

class KatasTest < AppModelsTestBase

  def self.hex_prefix
    'F3B488'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # katas[id]
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '8B1',
  'katas[bad-id] is not nil but any access to storer service raises' do
    bad_ids = [
      nil,          # not string
      Object.new,   # not string
      '',           # too short
      '123456789',  # too short
      '123456789f', # not 0-9A-F
      '123456789S'  # not 0-9A-F
    ]
    bad_ids.each do |bad_id|
      kata = katas[bad_id]
      refute_nil kata
      assert_raises { kata.age }
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'B3E',
  'katas[good-id] is kata with that id' do
    assert_equal kata_id, katas[kata_id].id
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # katas.completed(id)
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '939',
  'completed(id="") is empty string' do
    assert_equal '', katas.completed('')
  end

  test '6E2',
  'completed(id) is empty-string when id is less than 6 chars in length',
  'because trying to complete from a short id will waste time going through',
  'lots of candidates (on disk) with the likely outcome of no unique result' do
    id = kata_id[0..4]
    assert_equal 5, id.length
    assert_equal '', katas.completed(id)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '03B',
  'completed(id) is empty-string when no matches' do
    id = kata_id
    (0..7).each { |size|
      assert_equal '', katas.completed(id[0..size])
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '0AA',
  'completed(id) does not complete when 6+ chars and more than one match' do
    prefix = 'ABCDE1234'
    stub_make_kata(prefix + '5')
    stub_make_kata(prefix + '6')
    assert_equal '', katas.completed(prefix)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2AF',
  'completed(id) completes when 6+ chars and 1 match' do
    stub_make_kata(kata_id)
    assert_equal kata_id, katas.completed(kata_id[0..5])
  end

  private

  def stub_make_kata(kata_id)
    id_generator.stub(kata_id)
    make_language_kata
    kata_id
  end

end
