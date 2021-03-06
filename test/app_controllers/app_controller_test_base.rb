require_relative '../../test/all'
require_relative '../../config/environment'
require 'json'

class AppControllerTestBase < ActionDispatch::IntegrationTest

  include TestDomainHelpers
  include TestExternalHelpers
  include TestHexIdHelpers

  # - - - - - - - - - - - - - - - -

  def in_group(options={}, &block)
    create_custom_group(options)
    block.call(group)
  end

  def create_custom_group(options={})
    manifest = starter_manifest
    display_name = options[:display_name] || DEFAULT_DISPLAY_NAME
    manifest['display_name'] = display_name
    manifest['version'] = (options[:version] || 1)
    @id = model.group_create(manifest)
    nil
  end

  def group
    groups[@id]
  end

  # - - - - - - - - - - - - - - - -

  def in_kata(options={}, &block)
    create_language_kata(options)
    @files = plain(kata.files)
    @index = 0
    block.call(kata)
  end

  def create_language_kata(options = {})
    manifest = starter_manifest
    manifest['version'] = (options[:version] || 1)
    @id = model.kata_create(manifest)
    nil
  end

  def kata
    katas[@id]
  end

  # - - - - - - - - - - - - - - - -

  def sub_file(filename, from, to)
    refute_nil @files
    assert @files.keys.include?(filename), @files.keys.sort
    content = @files[filename]
    assert content.include?(from)
    @files[filename] = content.sub(from, to)
  end

  # - - - - - - - - - - - - - - - -

  def change_file(filename, content)
    refute_nil @files
    assert @files.keys.include?(filename), @files.keys.sort
    @files[filename] = content
  end

  # - - - - - - - - - - - - - - - -

  def post_run_tests(options = {})
    post '/kata/run_tests', params:run_test_params(options)
    @index += 1
    assert_response :success, response.body
  end

  # - - - - - - - - - - - - - - - -

  def run_test_params(options = {})
    {
      'format'           => 'js',
      'id'               => (options['id'] || kata.id),
      'avatar_index'     => kata.avatar_index,
      'version'          => kata.schema.version,
      'image_name'       => kata.manifest.image_name,
      'max_seconds'      => (options['max_seconds'] || kata.manifest.max_seconds),
      'hidden_filenames' => JSON.unparse(kata.manifest.hidden_filenames),
      'index'            => @index,
      'file_content'     => @files
    }
  end

  # - - - - - - - - - - - - - - - -

  def assert_join(gid)
    kata_id = join(gid)
    katas[kata_id]
  end

  def join(gid)
    model.group_join(gid)
  end

  def url_encoded(s)
    ERB::Util.url_encode(s)
  end

  # - - - - - - - - - - - - - - - -

  def json
    ActiveSupport::JSON.decode(html)
  end

  def html
    @response.body
  end

end
