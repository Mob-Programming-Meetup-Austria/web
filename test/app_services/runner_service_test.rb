require_relative 'app_services_test_base'

class RunnerServiceTest < AppServicesTestBase

  def self.hex_prefix
    '2BD'
  end

  def hex_setup
    set_saver_class('SaverService')
    set_runner_class('RunnerService')
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '74F',
  'smoke test runner.sha' do
    assert_sha(runner.sha)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '812',
  'run() is red' do
    in_kata { |kata|
      result = runner.run_cyber_dojo_sh(*run_args(kata))
      stdout = result['stdout']
      assert stdout['content'].include?('Expected: 42'), result
      assert stdout['content'].include?('  Actual: 54'), result
      assert_equal '', result['stderr']['content'], result
      assert_equal 1, result['status'], result
      assert_equal 'red', result['colour'], result
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '9DC',
  'deleting a file' do
    in_kata { |kata|
      args = run_args(kata)
      files = args[2]
      files['cyber-dojo.sh']['content'] += "\nrm readme.txt"
      args = [
        kata.manifest.image_name,
        kata.id,
        files,
        kata.manifest.max_seconds
      ]
      result = runner.run_cyber_dojo_sh(*args)
      assert_equal ['readme.txt'], result['deleted'].keys
    }
  end

  private # = = = = = = = = = = = = = = = = = = =

  def run_args(kata)
    [ kata.manifest.image_name,
      kata.id,
      kata.files,
      kata.manifest.max_seconds
    ]
  end

end
