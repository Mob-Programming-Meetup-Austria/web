require_relative 'app_services_test_base'

class StarterServiceTest < AppServicesTestBase

  def self.hex_prefix
    'D76AD9'
  end

  def hex_setup
    set_differ_class('NotUsed')
    set_storer_class('NotUsed')
    set_runner_class('NotUsed')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # starter
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  smoke_test '3AA',
  'smoke test starter-service' do
    json = starter.custom_choices
    assert_equal [ 'Yahtzee refactoring' ], json['major_names']
    assert_equal [
      'C# NUnit',
      'C++ (g++) assert',
      'Java JUnit',
      'Python unitttest'
    ], json['minor_names']
    assert_equal [[0,1,2,3]], json['minor_indexes']

    json = starter.languages_choices
    assert_equal [
      'C (gcc)',
      'C#',
      'C++ (g++)',
      'Python',
      'Ruby'
    ], json['major_names']
    assert_equal [
      'NUnit',
      'RSpec',
      'assert',
      'behave',
      'py.test',
      'unittest'
    ], json['minor_names']
    assert_equal [[2],[0],[2],[3,4,5],[1]], json['minor_indexes']

    json = starter.exercises_choices
    assert_equal [
      'Bowling_Game',
      'Fizz_Buzz',
      'Leap_Years',
      'Tiny_Maze'
    ], json['names']

    manifest = starter.custom_manifest('Yahtzee refactoring', 'C# NUnit')
    assert_equal 'Yahtzee refactoring, C# NUnit', manifest['display_name']

    manifest = starter.language_manifest('C#', 'NUnit', 'Fizz_Buzz')
    assert_equal 'C#, NUnit', manifest['display_name']

    manifest = starter.manifest('C')
    assert_equal 'C (gcc), assert', manifest['display_name']
  end

end