require_relative 'app_services_test_base'

class StorerServiceTest < AppServicesTestBase

  def self.hex_prefix
    'C0946E'
  end

  def hex_setup
    set_differ_class('NotUsed')
    set_storer_class('StorerService')
    set_runner_class('NotUsed')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '51A',
  'non-existant kata-id raises exception' do
    error = assert_raises (StandardError) {
      storer.kata_manifest(kata_id)
    }
    assert error.message.end_with?('kata_id:invalid')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '300',
  'smoke test storer.sha' do
    assert_sha storer.sha
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '301',
  'smoke test storer-service scenario' do
    assert_equal [], storer.katas_completions('34')

    manifest = starter.language_manifest('Ruby, MiniTest', 'Fizz_Buzz')
    manifest['created'] = creation_time
    kata_id = storer.kata_create(manifest)
    kata = katas[kata_id]
    assert storer.kata_exists?(kata.id)

    assert_equal({}, storer.kata_increments(kata.id))
    assert_equal kata_id, storer.katas_completed(kata.short_id)
    outer = kata.id[0..1]
    inner = kata.id[2..-1]
    assert storer.katas_completions(outer).include?(inner)
    assert_equal [], storer.avatars_started(kata.id)

    refute storer.avatar_exists?(kata.id, 'lion')
    assert_equal 'lion', storer.avatar_start(kata.id, ['lion'])
    assert storer.avatar_exists?(kata.id, 'lion')

    assert_equal({ 'lion' => [tag0] }, storer.kata_increments(kata.id))
    assert_equal ['lion'], storer.avatars_started(kata.id)
    files0 = storer.kata_manifest(kata.id)['visible_files']
    assert_equal files0, storer.tag_visible_files(kata.id, 'lion', tag=0)
    assert_equal [tag0], storer.avatar_increments(kata.id, 'lion')

    files1 = kata.visible_files
    files1['readme.txt'] = 'more info'
    args = []
    args << kata.id
    args << 'lion'
    args << files1
    args << (now = [2016,12,8, 8,3,23])
    args << (stdout = "Expected: 42\nActual: 54")
    args << (stderr = '')
    args << (colour = 'red')
    storer.avatar_ran_tests(*args)

    tag1 = { 'colour' => colour, 'time' => now, 'number' => 1 }
    assert_equal({ 'lion' => [tag0,tag1] }, storer.kata_increments(kata.id))
    assert_equal [tag0,tag1], storer.avatar_increments(kata.id, 'lion')

    files1['output'] = stdout + stderr
    assert_equal files1, storer.avatar_visible_files(kata.id, 'lion')

    json = storer.tags_visible_files(kata.id, 'lion', was_tag=0, now_tag=1)
    assert_equal files0, json['was_tag']
    assert_equal files1, json['now_tag']

    now2 = [2016,12,8, 8,4,15]
    forked_id = storer.tag_fork(kata.id, 'lion', -1, now2)
    assert_equal files1, storer.kata_manifest(forked_id)['visible_files']
  end

end
