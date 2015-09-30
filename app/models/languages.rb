# See comments at end of file

class Languages
  include Enumerable

  def self.cache_filename
    'languages_cache.json'
  end

  def initialize(dojo, path)
    @parent = dojo
    @path = path
    @path += '/' unless @path.end_with? '/'
  end

  attr_reader :path

  def each
    return enum_for(:each) unless block_given?
    languages.each { |language| yield language  }
  end

  def [](name)
    dir_name, test_dir_name = renamed(name)
    languages.find do |language|
      language.dir_name == dir_name &&
        language.test_dir_name == test_dir_name
    end
  end

  def indexer(name)
    languages2[map_to_display_name(name)]
  end

  def renamed(was_name)
    loop do
      now_name = new_name(was_name).join('-')
      break if now_name == was_name
      was_name = now_name
    end
    was_name.split('-')
  end

  def refresh_cache
    cache = {}
    dir.each_dir do |dir_name|
      disk[path + dir_name].each_dir do |test_dir_name|
        language = make_language(dir_name, test_dir_name)
        cache[language.display_name] = {
               dir_name: dir_name,
          test_dir_name: test_dir_name,
             image_name: language.image_name
        }
      end
    end
    write_json(self.class.cache_filename, cache)
  end

  def map_to_display_name(name)
    simplest = languages2[name.split('-').join(', ')]
    return simplest.display_name unless simplest.nil?
    renames = {
      # from way back when test name was _not_ part of language name
      ['BCPL']         => ['BCPL',         'all_tests_passed'],
      ['C']            => ['C (gcc)',      'assert'],
      ['C++']          => ['C++ (g++)',    'assert'],
      ['C#']           => ['C#',           'NUnit'],
      ['Clojure']      => ['Clojure',      '.test'],
      ['CoffeeScript'] => ['CoffeeScript', 'jasmine'],
      ['Erlang']       => ['Erlang',       'eunit'],
      ['Go']           => ['Go',           'testing'],
      ['Haskell']      => ['Haskell',      'hunit'],
      ['Java']         => ['Java',         'JUnit'],
      ['Javascript']   => ['Javascript',   'assert'],
      ['Perl']         => ['Perl',         'Test::Simple'],
      ['PHP']          => ['PHP',          'PHPUnit'],
      ['Python']       => ['Python',       'unittest'],
      ['Ruby']         => ['Ruby',         'Test::Unit'],
      ['Scala']        => ['Scala',        'scalatest'],
      # renamed
      ['C++',        'catch']            => ['C++ (g++)' , 'Catch'],
      ['Java',       'ApprovalTests']    => ['Java',       'Approval'],  # offline
      ['Java',       'JUnit','Mockito']  => ['Java',       'Mockito'],
      ['Javascript', 'mocha_chai_sinon'] => ['Javascript', 'Mocha+chai+sinon'],
      ['Perl',       'TestSimple']       => ['Perl',       'Test::Simple'],
      ['Ruby',       'Rspec']            => ['Ruby',       'RSpec'],     # capital S
      ['Ruby',       'TestUnit']         => ['Ruby',       'Test::Unit'],
      ['Python',     'pytest']           => ['Python',     'py.test'],   # dot
      # - in the wrong place
      ['Java', '1.8_Approval']     => ['Java', 'Approval'],  # offline
      ['Java', '1.8_Cucumber']     => ['Java', 'Cucumber'],
      ['Java', '1.8_JMock']        => ['Java', 'JMock'],
      ['Java', '1.8_JUnit']        => ['Java', 'JUnit'],
      ['Java', '1.8_Mockito']      => ['Java', 'Mockito'],
      ['Java', '1.8_Powermockito'] => ['Java', 'PowerMockito'],
      # replaced
      ['R', 'stopifnot'] => ['R', 'RUnit'],
      # renamed to distinguish from [C (clang)]
      ['C', 'assert']   => ['C (gcc)', 'assert'],
      ['C', 'Unity']    => ['C (gcc)', 'Unity'],
      ['C', 'CppUTest'] => ['C (gcc)', 'CppUTest'],
      # renamed to distinguish from [C++ (clang++)]
      ['C++', 'assert']     => ['C++ (g++)', 'assert'],
      ['C++', 'Boost.Test'] => ['C++ (g++)', 'Boost.Test'],
      ['C++', 'Catch']      => ['C++ (g++)', 'Catch'],
      ['C++', 'CppUTest']   => ['C++ (g++)', 'CppUTest'],
      ['C++', 'GoogleTest'] => ['C++ (g++)', 'GoogleTest'],
      ['C++', 'Igloo']      => ['C++ (g++)', 'Igloo'],
      ['C++', 'GoogleMock'] => ['C++ (g++)', 'GoogleMock'],

    }
    split = renames[name.split('-')]
    return nil if split.nil?
    tricky = split.join(', ')
    return tricky unless languages2[tricky].nil?
  end

  private

  include ExternalParentChain

  def new_name(name)
    # maps from a language&test display_name into a
    # Language-Test name corresponding to its Language/Test/ *folder*
    # See comment at bottom of file.
    renames = {
      # from way back when test name was not part of language name
      'BCPL'         => 'BCPL-all_tests_passed',
      'C'            => 'C-assert',
      'C++'          => 'C++-assert',
      'C#'           => 'C#-NUnit',
      'Clojure'      => 'Clojure-.test',
      'CoffeeScript' => 'CoffeeScript-jasmine',
      'Erlang'       => 'Erlang-eunit',
      'Go'           => 'Go-testing',
      'Haskell'      => 'Haskell-hunit',
      'Java'         => 'Java-JUnit',
      'Javascript'   => 'Javascript-assert',
      'Perl'         => 'Perl-TestSimple',
      'PHP'          => 'PHP-PHPUnit',
      'Python'       => 'Python-unittest',
      'Ruby'         => 'Ruby-TestUnit',
      'Scala'        => 'Scala-scalatest',

      # renamed
      'Java-ApprovalTests' => 'Java-Approval',
      'Java-JUnit-Mockito' => 'Java-Mockito',
      'Ruby-Test::Unit'    => 'Ruby-TestUnit',

      # display name is different to folder name
      'C++-catch'                   => 'C++-Catch',
      'Javascript-Mocha+chai+sinon' => 'Javascript-mocha_chai_sinon',
      'Perl-Test::Simple'           => 'Perl-TestSimple',
      'Python-py.test'              => 'Python-pytest',
      'Ruby-RSpec'                  => 'Ruby-Rspec',

      # - in the wrong place
      'Java-1.8_Approval'      => 'Java-Approval',
      'Java-1.8_Cucumber'      => 'Java-Cucumber',
      'Java-1.8_JMock'         => 'Java-JMock',
      'Java-1.8_JUnit'         => 'Java-JUnit',
      'Java-1.8_Mockito'       => 'Java-Mockito',
      'Java-1.8_Powermockito'  => 'Java-PowerMockito',

      # replaced
      'R-stopifnot' => 'R-RUnit',

      # renamed to distinguish from [C (clang)]
      'C-assert'   => 'C (gcc)-assert',
      'C-Unity'    => 'C (gcc)-Unity',
      'C-CppUTest' => 'C (gcc)-CppUTest',

      # renamed to distinguish from [C++ (clang++)]
      'C++-assert'     => 'C++ (g++)-assert',
      'C++-Boost.Test' => 'C++ (g++)-Boost.Test',
      'C++-Catch'      => 'C++ (g++)-Catch',
      'C++-CppUTest'   => 'C++ (g++)-CppUTest',
      'C++-GoogleTest' => 'C++ (g++)-GoogleTest',
      'C++-Igloo'      => 'C++ (g++)-Igloo',
      'C++-GoogleMock' => 'C++ (g++)-GoogleMock',

      # multiple language versions (4.8.4 & 4.9)
      'C++ (g++)-assert'     => 'g++4.8.4-assert',
      'C++ (g++)-Boost.Test' => 'g++4.8.4-Boost.Test',
      'C++ (g++)-Catch'      => 'g++4.8.4-Catch',
      'C++ (g++)-CppUTest'   => 'g++4.8.4-CppUTest',
      'C++ (g++)-GoogleTest' => 'g++4.8.4-GoogleTest',
      'C++ (g++)-Igloo'      => 'g++4.8.4-Igloo',
      'C++ (g++)-GoogleMock' => 'g++4.9-GoogleMock',

      # multiple language versions (1.9.3 & 2.1.3)
      'Ruby-Approval'      => 'Ruby1.9.3-Approval',
      'Ruby-Cucumber'      => 'Ruby1.9.3-Cucumber',
      'Ruby-TestUnit'      => 'Ruby1.9.3-TestUnit',
      'Ruby-Rspec'         => 'Ruby1.9.3-Rspec',
      'Ruby-MiniTest'      => 'Ruby2.1.3-MiniTest',

      # multiple language versions
      'Javascript-jasmine'     => 'Javascript-jasmine2.3',
      'Javascript-qunit+sinon' => 'Javascript-qunit_sinon'
    }
    (renames[name] || name).split('-')
  end

  def languages
    @languages ||= read_cache
  end

  def languages2
    @languages2 ||= read_cache2
  end

  def read_cache
    cache = []
    read_json(self.class.cache_filename).each do |display_name, language|
           dir_name = language['dir_name']
      test_dir_name = language['test_dir_name']
         image_name = language['image_name']
      cache << make_language(dir_name, test_dir_name, display_name, image_name)
    end
    cache
  end

  def read_cache2
    cache = {}
    read_json(self.class.cache_filename).each do |display_name, language|
           dir_name = language['dir_name']
      test_dir_name = language['test_dir_name']
         image_name = language['image_name']
      cache[display_name] = make_language(dir_name, test_dir_name, display_name, image_name)
    end
    cache
  end

  def make_language(dir_name, test_dir_name, display_name = nil, image_name = nil)
    Language.new(self, dir_name, test_dir_name, display_name, image_name)
  end

end

# - - - - - - - - - - - - - - - - - - - - - - - -
# Upgrading? Multiple language versions?
# - - - - - - - - - - - - - - - - - - - - - - - -
# It's common to want to add a new test-framework to
# an existing language and, when doing this, to take
# advantage of upgrading the language to a newer version.
#
# For example
#    Ruby1.9.3/Approval
#    Ruby1.9.3/Cucumber
#    Ruby1.9.3/Rspec
#    Ruby1.9.3/TestUnit
# existed when I wanted to add MiniTest as a new Ruby test-framework.
# By then the latest Ruby version was 2.1.3
#    Ruby2.1.3/MiniTest
#
# I didn't want to have to upgrade the existing Ruby1.9.3 test-frameworks
# to Ruby2.1.3. But... on the create page I wanted all the different
# Ruby test-frameworks (from two different versions of Ruby) to appear
# under the *same* language name in the language? column.
# This is why a language/test's  manifest.json file has a display_name entry.
# It is the display_name that governs the language/test's names as they appear
# on the create page. Not the folder names. Not the docker container image_name.
#
# Many people will have built their own cyber-dojo servers and might *not* want
# or need to upgrade their servers to use the latest docker containers for
# the latest language/test even if it exists.
# This means the cyberdojofoundation docker index needs to keep old versions of
# language/test docker containers even when newer ones exist.
# Viz, a docker container name needs to have a version number in it.

# Further, if you upgrade a language/test to a newer version
# and delete the old version of the docker container from your server,
# you still want to be able to fork from a kata done in the old version.
# And when you do such a fork you want the new kata to use the new version.
# So what is stored in the kata's manifest is *not* the docker container's
# image_name but the display_name.
#
# The renamed() function above maps the display_name
# into a name in the form "Language-Test" which corresponds to its
# Language/Test folder which in turn contains its manifest.json file.
#
# It's a bit fiddly because historically the language-&-test
# were *not* separated into distinct nested folders.
# You can still see the remnants of this in the language/test/manifest.json's
# display_name which contains the display name of the *both* the language
# *and* the test-framework (separated by a comma).
#
# - - - - - - - - - - - - - - - - - - - - - - - -
# Some languages/ sub-folders have been renamed.
# This creates a problem for practice-sessions done
# before the rename that you now wish to review or
# fork from. Particularly for sessions with
# well known id's such as the refactoring dojos.
# For example...
# Suppose an old practice-session was done with a
# language name of 'Java' then in Kata.rb
# manifest['language'] will be 'Java'
# However kata.language  is defined as
#   dojo.languages[manifest['language']]
# And Languages' [] index operator (above)
# maps the incoming name to the latest name.
# Thus
#    old_name = kata.manifest['language']
#    language = dojo.languages[old_name]
#    new_name = language.name
#    assert_sometimes old_name != new_name
# - - - - - - - - - - - - - - - - - - - - - - - -
