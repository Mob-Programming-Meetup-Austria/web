require_relative 'app_controller_test_base'

class SetupDefaultStartPointControllerTest < AppControllerTestBase

  def self.hex_prefix
    '59C9F4'
  end

  def hex_setup
    set_starter_class('StarterService')
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '020',
  'show displays language,testFramework list and exercise list' do
    show

    assert listed?(ruby_minitest)
    assert listed?(ruby_rspec)
    assert valid_language_index?

    assert listed?(bowling_game)
    assert listed?(fizz_buzz)
    assert listed?(leap_years)
    assert listed?(tiny_maze)
    assert valid_exercise_index?
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test 'BA3',
  'show defaults to language,test-framework and exercise of kata',
  'whose full-id is passed in URL (to encourage repetition)' do
    in_kata(:stateless) {}
    assert_equal ruby_minitest, kata.display_name
    show 'id' => kata.id

    start_points = starter.language_start_points
    assert_equal ruby_minitest, start_points['languages'][language_index]
    assert_equal fizz_buzz,     start_points['exercises'].keys.sort[exercise_index]
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test 'BA4',
  'show ok when display_name of full-id passed in URL not a current start-point' do
    manifest = starter.language_manifest(ruby_minitest, fizz_buzz)
    manifest['id'] = kata_id
    manifest['created'] = time_now
    manifest['display_name'] = 'Wuby, MiniTest'
    manifest['exercise'] = 'Fizzy_Buzzy'
    storer.create_kata(manifest)

    show 'id' => manifest['id']

    assert valid_language_index?
    assert valid_exercise_index?
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '565',
  'show ok when kata_id is invalid' do
    show 'id' => '379C8ABFDF'

    assert listed?(ruby_minitest)
    assert listed?(ruby_rspec)
    assert valid_language_index?

    assert listed?(bowling_game)
    assert listed?(fizz_buzz)
    assert listed?(leap_years)
    assert listed?(tiny_maze)
    assert valid_exercise_index?
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '3D8', %w(
  save_group
  creates a new kata
  with the given display_name
  and does not start any avatars
  and redirects to kata/group page ) do
    language = ruby_rspec
    exercise = leap_years
    params = {
      'language' => language,
      'exercise' => exercise
    }
    id = save_group(params)
    kata = katas[id]
    assert_equal language,  kata.display_name
    assert_equal exercise, kata.exercise
    started = kata.avatars.started
    assert_equal 0, started.size
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '3D9', %w(
  save_individual
  creates a new kata
  with the given language+test and exercise
  and starts a new avatar
  and redirects to kata/individual page ) do
    language = ruby_minitest
    exercise = fizz_buzz
    params = {
      'language' => language,
      'exercise' => exercise
    }
    id,avatar = save_individual(params)
    kata = katas[id]
    assert_equal language, kata.display_name
    assert_equal exercise, kata.exercise
    started = kata.avatars.started
    assert_equal 1, started.size
    assert_equal [avatar], started.keys
  end


  private # = = = = = = = = = = = = = = = = = =

  def show(params = {})
    get "/#{controller}/show", params:params
    assert_response :success
  end

  def save_individual(params)
    get "/#{controller}/save_individual", params:params
    assert_response :redirect
    regex = /^(.*)\/kata\/individual\/([0-9A-Z]*)\?avatar=([a-z]*)$/
    assert m = regex.match(@response.redirect_url)
    id = m[2]
    avatar = m[3]
    [id,avatar]
  end

  def save_group(params)
    get "/#{controller}/save_group", params:params
    assert_response :redirect
    regex = /^(.*)\/kata\/group\/([0-9A-Z]*)$/
    assert m = regex.match(@response.redirect_url)
    id = m[2]
  end

  def controller
    'setup_default_start_point'
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def valid_language_index?
    start_points = starter.language_start_points
    max = start_points['languages'].size
    (0...max).include?(language_index)
  end

  def language_index
    md = /var selectedLanguage = \$\('#language_' \+ '(\d+)'\);/.match(html)
    refute_nil md
    md[1].to_i
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def valid_exercise_index?
    start_points = starter.language_start_points
    max = start_points['exercises'].size
    (0...max).include?(exercise_index)
  end

  def exercise_index
    md = /var selectedExercise = \$\('#exercise_' \+ '(\d+)'\);/.match(html)
    refute_nil md
    md[1].to_i
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def bowling_game
    'Bowling_Game'
  end

  def fizz_buzz
    'Fizz_Buzz'
  end

  def leap_years
    'Leap_Years'
  end

  def tiny_maze
    'Tiny_Maze'
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def ruby_minitest
    'Ruby, MiniTest'
  end

  def ruby_rspec
    'Ruby, RSpec'
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def listed?(entry)
    html.include? "data-name=#{quoted(entry)}"
  end

  def quoted(s)
    '"' + s + '"'
  end

end
