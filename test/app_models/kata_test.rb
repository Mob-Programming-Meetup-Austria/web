require_relative 'app_models_test_base'
require_relative '../../app/services/saver_service'

class KataTest < AppModelsTestBase

  def self.hex_prefix
    'Fb9'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test 'B7F', %w(
  using existing kata.methods (except for exists?)
  when params does not specify a version number
  forces schema.version determination via the manifest
  ) do
    set_saver_class('SaverService')
    katas = Katas.new(self, {})
    kata = katas['5rTJv5']
    assert_equal 'Ruby, MiniTest', kata.manifest.display_name
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -
  # exists?

  v_tests [0,1], '760', %w(
  exists? is true,
  for a well-formed kata-id that exists,
  when saver is online
  ) do
    in_new_kata do |kata|
      assert kata.exists?
      assert_schema_version(kata)
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  v_tests [0,1], '761', %w(
  exists? is false,
  for a well-formed kata-id that does not exist,
  when saver is online
  ) do
    refute katas['123AbZ'].exists?
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  v_tests [0,1], '762', %w(
  exists? is false,
  for a malformed kata-id,
  when saver is online
  ) do
    refute katas[42].exists?, 'Integer'
    refute katas[nil].exists?, 'nil'
    refute katas[[]].exists?, '[]'
    refute katas[{}].exists?, '{}'
    refute katas[true].exists?, 'true'
    refute katas[''].exists?, 'length == 0'
    refute katas['12345'].exists?, 'length == 5'
    refute katas['12345i'].exists?, '!id?()'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  v_tests [0,1], '763', %w(
  exists? raises,
  when kata-id is well-formed,
  and saver is offline
  ) do
    set_saver_class('SaverExceptionRaiser')
    assert_raises(SaverService::Error) {
      katas['123AbZ'].exists?
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  v_tests [0,1], '861', %w(
  group-version propagates to joined kata-version
  ) do
    in_new_group do |group|
      kata = group.join
      assert_equal kata.schema.version, group.schema.version
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  v_tests [0,1], '862', %w(
  an individual kata is created from a well-formed manifest,
  is empty,
  and is not a member of a group,
  ) do
    in_new_kata do |kata|
      assert kata.exists?
      assert_schema_version(kata)
      assert_equal 0, kata.age

      assert_nil kata.stdout
      assert_nil kata.stderr
      assert_nil kata.status

      refute kata.active?
      assert_equal [], kata.lights

      refute kata.group?
      refute_nil kata.group # NullObject pattern
      refute kata.group.exists?
      assert_nil kata.group.id
      assert_equal '', kata.avatar_name
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  v_tests [0,1], '863', %w(
  a new group-kata can be created by joining a group,
  is empty,
  and is a member of the group
  ) do
    indexes = (0..63).to_a.shuffle
    in_new_group do |group|
      kata = group.join(indexes)

      assert_schema_version(kata)

      assert kata.exists?

      assert_equal 0, kata.age

      assert_nil kata.stdout
      assert_nil kata.stderr
      assert_nil kata.status

      refute kata.active?
      assert_equal [], kata.lights

      assert kata.group?
      assert kata.group.exists?
      refute_nil kata.group
      assert_equal group.id, kata.group.id
      assert_equal Avatars.names[indexes[0]], kata.avatar_name

      assert_equal 'Ruby, MiniTest', kata.manifest.display_name
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  v_tests [0,1], '864', %w(
  after run_tests()/ran_tests(),
  the kata is active,
  the kata is a bit older,
  there is a new traffic-light event,
  which is now the most recent event
  ) do
    @time = TimeStub.new([2018,11,1, 9,13,56,6574])
    in_new_kata do |kata|
      assert_schema_version(kata)
      stdout = content('dfg')
      stderr = content('uystd')
      status = 3
      colour = 'red'
      now = [2018,11,1, 9,14,9,9154]
      kata.ran_tests(1, kata.files, now, duration, stdout, stderr, status, colour)

      assert_equal 13, kata.age
      assert kata.active?
      assert_equal 2, kata.events.size
      assert_equal 1, kata.lights.size
      light = kata.lights[0]
      assert_equal stdout, light.stdout
      assert_equal stderr, light.stderr
      assert_equal status, light.status
      assert_equal stdout, kata.stdout
      assert_equal stderr, kata.stderr
      assert_equal status, kata.status
      # event files can include pseudo output-files to help differ
      expected = kata.files.merge({
          'stdout' => light.stdout,
          'stderr' => light.stderr,
          'status' => { 'content' => light.status.to_s }
      })
      assert_equal expected, light.files(:with_output)
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  v_tests [0,1], '865', %w(
  an event's manifest is ready to create a new kata from
  ) do
    in_new_kata do |kata|
      assert_schema_version(kata)
      stdout = content('dfsdf')
      stderr = content('76546')
      status = 3
      colour = 'red'
      kata.ran_tests(1, kata.files, time.now, duration, stdout, stderr, status, colour)

      emanifest = kata.events[1].manifest
      refute_nil emanifest
      assert_nil emanifest['id']
      assert_nil emanifest['created']
      assert_equal kata.files, emanifest['visible_files']
      assert_equal kata.manifest.display_name, emanifest['display_name']
      assert_equal kata.manifest.image_name, emanifest['image_name']
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  v_tests [0,1], '866', %w(
  kata.event(-1) returns the most recent event
  ) do
    in_new_kata do |kata|
      assert_schema_version(kata)
      assert_equal kata.event(0), kata.event(-1)
      stdout = content('xxxx')
      stderr = content('')
      status = 0
      colour = 'green'
      kata.ran_tests(1, kata.files, time.now, duration, stdout, stderr, status, colour)
      assert_equal 'xxxx', kata.event(-1)['stdout']['content']
      assert_equal kata.event(1), kata.event(-1)
      stdout = content('')
      stderr = content('syntax-error')
      status = 1
      kata.ran_tests(2, kata.files, time.now, duration, stdout, stderr, status, colour)
      assert_equal 'syntax-error', kata.event(-1)['stderr']['content']
      assert_equal kata.event(2), kata.event(-1)
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  v_tests [0,1], '824', %w(
  given a saver outage during a session
  when kata.event(-1) is called
  then v0 raises
  but v1 handles it
  ) do
    in_new_kata do |kata|
      assert_schema_version(kata)
      stdout = content('aaaa')
      stderr = content('bbbb')
      status = 1
      colour = 'red'
      kata.ran_tests(index=1, kata.files, time.now, duration, stdout, stderr, status, colour)
      # saver-outage for index=2,3,4,5
      stdout['content'] = 'x1x2x3'
      kata.ran_tests(index=6, kata.files, time.now, duration, stdout, stderr, status, colour)
      if v_test?(0)
        assert_raises { kata.event(-1) }
      else
        assert_equal 'x1x2x3', kata.event(-1)['stdout']['content']
      end
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  v_tests [0,1], '825', %w(
  given two laptops as the same avatar
  when one is behind (has not synced by hitting refresh in their browser)
  and they hit the [test] button
  a SaverService::Error is raised
  and a new event is not created in the saver
  ) do
    set_saver_class('SaverService')
    in_new_kata do |kata|
      stdout = content('aaaa')
      stderr = content('bbbb')
      status = 1
      # 1st avatar
      kata.ran_tests(index=1, kata.files, time.now, duration, stdout, stderr, status, 'red')
      kata.ran_tests(index=2, kata.files, time.now, duration, stdout, stderr, status, 'amber')
      kata.ran_tests(index=3, kata.files, time.now, duration, stdout, stderr, status, 'green')

      events = kata.events
      assert_equal 4, events.size, :event_not_appended_to_events_json
      assert_raises(SaverService::Error) {
        kata.event(4).files # /4/event.json not created
      }

      # 2nd avatar - no refresh, so index not advanced to 2
      error = assert_raises(SaverService::Error) {
        kata.ran_tests(index=1, kata.files, time.now, duration, stdout, stderr, status, 'green')
      }

      events = kata.events
      assert_equal 4, events.size, :event_not_appended_to_events_json
      assert_raises(SaverService::Error) {
        kata.event(4).files # /4.event.json not created
      }
      assert_equal 0, events[0].index # creation
      assert_equal 1, events[1].index
      assert_equal :red, events[1].colour
      assert_equal 2, events[2].index
      assert_equal :amber, events[2].colour
      assert_equal 3, events[3].index
      assert_equal :green, events[3].colour
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  v_tests [0,1], '826', %w(
  the default colour-theme is light as its better for projection
  ) do
    in_new_kata do |kata|
      assert_equal  'light', kata.theme
    end
  end

  v_tests [0,1], '827', %w(
  the default for colour-syntax is on
  ) do
    in_new_kata do |kata|
      assert_equal  'on', kata.colour
    end
  end


  v_tests [0,1], '828', %w(
  the default for prediction is off
  ) do
    in_new_kata do |kata|
      assert_equal  'off', kata.predict
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  v_tests [0,1], '926', %w(
  setting the colour-theme is persistent
  ) do
    in_new_kata do |kata|
      kata.theme = 'light'
      assert_equal  'light', kata.theme
      kata.theme = 'dark'
      assert_equal  'dark', kata.theme
    end
  end

  v_tests [0,1], '927', %w(
  setting the colour-syntax is persistent
  ) do
    in_new_kata do |kata|
      kata.colour = 'off'
      assert_equal  'off', kata.colour
      kata.colour = 'on'
      assert_equal  'on', kata.colour
    end
  end

  v_tests [0,1], '928', %w(
  setting the prediction is persistent
  ) do
    in_new_kata do |kata|
      kata.predict = 'on'
      assert_equal  'on', kata.predict
      kata.predict = 'off'
      assert_equal  'off', kata.predict
    end
  end

end
