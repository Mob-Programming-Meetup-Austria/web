
module TestDomainHelpers # mix-in

  def in_group(runner_choice = :stateless, &block)
    manifest = make_manifest({ 'display_name' => display_name(runner_choice) })
    group = groups.new_group(manifest)
    block.call(group)
  end

  # - - - - - - - - - - - - - - - -

  def in_kata(runner_choice = :stateless, &block)
    kata = make_language_kata({ 'display_name' => display_name(runner_choice) })
    begin
      block.call(kata)
    ensure
      runner.kata_old(kata.manifest.image_name, kata.id)
    end
  end

  # - - - - - - - - - - - - - - - -

  def make_language_kata(options = {})
    katas.new_kata(make_manifest(options))
  end

  def make_manifest(options = {})
    display_name = options['display_name'] || default_language_name
    exercise_name = options['exercise'] || default_exercise_name
    manifest = starter.language_manifest(display_name, exercise_name)
    manifest['created'] = (options['created'] || time_now)
    manifest['id'] = (options['id'] || kata_id)
    manifest
  end

  def default_language_name
    'Ruby, MiniTest'
  end

  def default_exercise_name
    'Fizz_Buzz'
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  def groups
    Groups.new(self)
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  def katas
    Katas.new(self)
  end

  def kata
    katas[kata_id]
  end

  def kata_id
    hex_test_kata_id
  end

  def time_now(now = Time.now)
    [now.year, now.month, now.day, now.hour, now.min, now.sec, now.usec]
  end

  def duration
    1.6543
  end

  def display_name(runner_choice = :stateless)
    { stateless: 'Ruby, MiniTest',
       stateful: 'Ruby, RSpec'
    }[runner_choice]
  end

end
