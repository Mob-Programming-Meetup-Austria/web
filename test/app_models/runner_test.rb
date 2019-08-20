require_relative 'app_models_test_base'

class RunnerTest < AppModelsTestBase

  def self.hex_prefix
    'Nn2'
  end

  def hex_setup
    set_runner_class('RunnerService')
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '149',
  'red: expected=42, actual=6*9' do
    params = gcc_assert_params
    result = kata.run_tests(params)
    assert_equal false, result[0]['timed_out']
    assert_equal 'red', colour_of(kata, result[0])
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '150',
  'amber: file large than max_file_size is truncated' do
    params = gcc_assert_params
    large = "/*" + ('-'* (51*1024)) + "*/"
    params[:file_content]['large.c'] = large
    result = kata.run_tests(params)
    assert_equal false, result[0]['timed_out']
    assert_equal 'amber', colour_of(kata, result[0])
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '151',
  'green: expected=42, actual=6*7' do
    params = gcc_assert_params
    src = params[:file_content]['hiker.c']
    src.sub!('6 * 9', '6 * 7')
    params[:file_content]['hiker.c'] = src
    result = kata.run_tests(params)
    assert_equal false, result[0]['timed_out']
    assert_equal 'green', colour_of(kata, result[0])
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '152',
  'timed_out: infinite loop' do
    params = gcc_assert_params
    src = params[:file_content]['hiker.c']
    src.sub!('return', 'for(;;);return')
    params[:file_content]['hiker.c'] = src
    result = kata.run_tests(params, max_seconds = 2)
    assert_equal true, result[0]['timed_out']
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # faulty

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # hidden_filenames

  private

  def gcc_assert_params
    kata = make_language_kata({ 'display_name' => 'C (gcc), assert' })
    run_params(kata)
  end

  def run_params(kata)
    {
      id:kata.id,
      image_name:kata.manifest.image_name,
      max_seconds:kata.manifest.max_seconds,
      file_content:plain(kata.files),
      hidden_filenames:'[]'
    }
  end

  def colour_of(kata, result)
    stdout = result['stdout']['content']
    stderr = result['stderr']['content']
    status = result['status'].to_i
    ragger.colour(kata.manifest.image_name, kata.id, stdout, stderr, status)
  end

end
