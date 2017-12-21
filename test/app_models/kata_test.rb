require_relative 'app_models_test_base'
require_relative '../app_lib/delta_maker'

class KataTest < AppModelsTestBase

  test '677A57',
  'id reads back as set' do
    id = unique_id
    kata = make_kata({ 'id' => id })
    assert_equal id, kata.id
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '6779AE',
  'when kata has no avatars',
  'then it is not active' do
    kata = make_kata
    refute kata.active?
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '67740E',
  "when kata's avatars have 0 traffic-lights",
  'then it is not active' do
    kata = make_kata
    kata.start_avatar(['hippo'])
    kata.start_avatar(['lion'])
    refute kata.active?
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '677DD3',
  'when kata has at least one avatar with 1 or more traffic-lights',
  'then kata is active' do
    kata = make_kata

    hippo = kata.start_avatar(['hippo'])
    first_time = [2014,2,15, 8,54,6]
    DeltaMaker.new(hippo).run_test(first_time)

    lion = kata.start_avatar(['lion'])
    second_time = [2014,2,15, 8,54,34]
    DeltaMaker.new(lion).run_test(second_time)

    assert kata.active?
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '677205',
  'make_kata with default created-property uses time-now' do
    now = Time.now
    kata = make_kata
    created = Time.mktime(*kata.created)
    past = Time.mktime(now.year, now.month, now.day, now.hour, now.min, now.sec)
    diff = created - past
    assert 0 <= diff && diff <= 1, "created=#{created}, past=#{past}, diff=#{past}"
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '67751F',
  'kata properties are union of language properties and exercise instruction' do
    id = unique_id
    created = [ 2017,12,21, 10,40,24 ]
    hash = {
      'id'       => id,
      'created'  => created,
      'language' => 'Python-py.test',
      'exercise' => 'Fizz_Buzz',
    }
    kata = make_kata(hash)

    assert_equal id, kata.id
    assert_equal Time.mktime(*created), kata.created
    assert_equal 'stateless', kata.runner_choice
    assert_equal 'cyberdojofoundation/python_pytest', kata.image_name
    assert_equal 4, kata.tab_size
    assert_equal 'Python, py.test', kata.display_name
    assert_equal '.py', kata.filename_extension
    assert_equal [], kata.progress_regexs # TODO: REVISIT
    assert_equal [], kata.highlight_filenames
    assert_equal ['cyber-dojo.sh','makefile','Makefile','unity.license.txt'], kata.lowlight_filenames
    assert_equal 'Python-py.test', kata.language
    assert_equal 'Fizz_Buzz', kata.exercise
    assert_equal 10, kata.max_seconds
    text = 'Write a program that prints the numbers from 1 to 100.'
    assert kata.visible_files['instructions'].start_with?(text)
    assert_equal '', kata.visible_files['output']
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '677632',
  'started_avatars is initially empty array' do
    @kata = make_kata
    assert_equal [], avatars_names
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '677B48',
  'start_avatar() with name that is not a known avatar is nil' do
    kata = make_kata
    assert_nil kata.start_avatar(['sellotape'])
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '677C43',
  %w( start_avatar() in language with stateful-runner
      with specific name succeeds
      when avatar has not yet started ).join(' ').to_s do
    @kata = make_kata({ 'language' => 'C (gcc)-assert' })
    hippo = @kata.start_avatar(['hippo'])
    refute_nil hippo
    assert_equal 'hippo', hippo.name
    assert_equal ['hippo'], avatars_names
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '677C44',
  %w( start_avatar() in language with stateless-runner
      with specific name succeeds
      when avatar has not yet started ).join(' ').to_s do
    @kata = make_kata({ 'language' => 'Python-unittest' })
    hippo = @kata.start_avatar(['hippo'])
    refute_nil hippo
    assert_equal 'hippo', hippo.name
    assert_equal ['hippo'], avatars_names
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '6773FA',
  'start_avatar() with specific name is nil when avatar has already started' do
    kata = make_kata
    kata.start_avatar(['hippo'])
    avatar = kata.start_avatar(['hippo'])
    assert_nil avatar
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '6776C8',
  'start_avatar() with specific names tries them in order' do
    @kata = make_kata
    names = %w(cheetah lion panda)

    cheetah = @kata.start_avatar(names)
    refute_nil cheetah
    assert_equal 'cheetah', cheetah.name
    assert_equal ['cheetah'], avatars_names

    lion = @kata.start_avatar(names)
    refute_nil lion
    assert_equal 'lion', lion.name
    assert_equal ['cheetah','lion'], avatars_names

    panda = @kata.start_avatar(names)
    refute_nil panda
    assert_equal 'panda', panda.name
    assert_equal ['cheetah','lion','panda'], avatars_names

    assert_nil @kata.start_avatar(names)
    assert_equal names.sort, avatars_names
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '67741A',
  'start_avatar() succeeds once for each avatar-name then is full' do
    kata = make_kata
    created = []
    Avatars.names.length.times do
      avatar = kata.start_avatar
      refute_nil avatar
      created << avatar.name
    end
    assert_equal Avatars.names.sort, created.sort
    assert_nil kata.start_avatar
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '677A3D',
  'start_avatar() starts avatars in random order' do
    kata = make_kata
    created = []
    Avatars.names.length.times do
      avatar = kata.start_avatar
      refute_nil avatar
      created << avatar.name
    end
    assert_equal Avatars.names.sort, created.sort
    refute_equal created, created.sort
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '677D61',
  'start_avatar() seamlessly resurrects when',
  'collector has collected the runner containers/volumes' do
    set_runner_class('RunnerService')
    kata = make_kata({ 'language' => 'C (gcc)-assert' })
    assert kata.runner_choice == 'stateful'
    runner.kata_old(kata.image_name, kata.id)
    begin
      avatar = kata.start_avatar
      runner.avatar_old(kata.image_name, kata.id, avatar.name)
      refute_nil avatar
    ensure
      runner.kata_old(kata.image_name, kata.id)
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

=begin
  test '677712',
  'for a kata created before the start_point re-architecture',
  'attempt to retrieve the full-manifest properties from the start-point' do
    kata_id = '677712F0E7'
    manifest = {
      'id'       => kata_id,
      'language' => 'C-assert',
      'exercise' => 'Fizz_Buzz',
    }
    storer.create_kata(manifest)

    property_names = %w(
      display_name
      image_name
      filename_extension
      progress_regexs
      highlight_filenames
      lowlight_filenames
      runner_choice
    )
    kata = katas[kata_id]
    property_names.each { |property_name| refute_nil kata.send(property_name) }
    assert_equal 'C (gcc), assert', kata.display_name
  end
=end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private

  def avatars_names
    @kata.avatars.map(&:name).sort
  end

end
