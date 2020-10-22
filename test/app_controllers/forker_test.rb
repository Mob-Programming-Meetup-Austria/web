require_relative 'app_controller_test_base'

class ForkerControllerTest < AppControllerTestBase

  def self.hex_prefix
    '3E9'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'Kw3', %w(
  fork_individual() from a kata that IS in a group
  results in a new kata that is NOT in a group
  ) do
    in_group { |group|
      kata = assert_join(group.id)
      @id = kata.id
      @files = plain(kata.files)
      @index = 0
      post_run_tests # 1
      fork_individual(:json, kata.id, index=1)
      assert forked?
      forked_kata = katas[json['id']]
      assert forked_kata.exists?
      refute forked_kata.group?
      m = model.kata_manifest(forked_kata.id)
      refute m.has_key?('group_id')
      refute m.has_key?('group_index')
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # format: json
  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '32E', %w(
  when id,index are all ok
  format=json fork_individual() returns
  the new individual session's id
  which designates a kata at the latest version) do
    in_kata { |kata|
      post_run_tests # 1
      fork_individual(:json, kata.id, index=1)
      assert forked?
      forked_kata = katas[json['id']]
      assert forked_kata.exists?
      assert_equal 1, forked_kata.schema.version
      refute forked_kata.group?
      assert_equal kata.manifest.image_name, forked_kata.manifest.image_name
      assert_equal kata.files, forked_kata.files
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '32F', %w(
  when id,index are all ok
  format=json fork_group() returns
  new group session's id is
  which designates a group at the latest version) do
    in_kata { |kata|
      post_run_tests # 1
      fork_group(:json, kata.id, index=1)
      assert forked?
      forked_group = groups[json['id']]
      assert forked_group.exists?
      assert_equal 1, forked_group.schema.version
      assert_equal kata.manifest.image_name, forked_group.manifest.image_name
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # format: html
  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '7D6', 'forker/fork_group (html)' do
    in_kata { |kata|
      post_run_tests # 1
      fork_group(:html, kata.id, index=1)
      assert_response :redirect
      regex = /^(.*)\/creator\/enter\?id=([0-9A-Za-z]*)$/
      assert m = regex.match(@response.redirect_url)
      gid = m[2]
      assert_equal 6, gid.size
      group = groups[gid]
      assert group.exists?
    }
  end

  test '7D7', 'forker/fork_individual (html)' do
    in_kata { |kata|
      post_run_tests # 1
      fork_individual(:html, kata.id, index=1)
      assert_response :redirect
      regex = /^(.*)\/creator\/enter\?id=([0-9A-Za-z]*)$/
      assert m = regex.match(@response.redirect_url)
      kid = m[2]
      assert_equal 6, kid.size
      kata = katas[kid]
      assert kata.exists?
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # fork_....(id, index=-1)
  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'P8w', %w( JSON: fork_individual(id,index=-1) forks from latest index ) do
    id = '5rTJv5'
    kata = katas[id]
    assert kata.exists?
    assert_equal 0, kata.schema.version

    fork_individual(:json, id , -1)

    assert forked?
    forked_kata = katas[json['id']]
    assert forked_kata.exists?
    assert_equal 1, forked_kata.schema.version, :latest_version
    assert_equal kata.manifest.image_name, forked_kata.manifest.image_name
  end

  # . . . . . . . . . . . . .

  test 'P8x', %w( HTML: fork_individual(id,index=-1) forks from latest index ) do
    id = '5rTJv5'
    kata = katas[id]
    assert kata.exists?
    assert_equal 0, kata.schema.version

    fork_individual(:html, id , -1)

    assert_response :redirect
    regex = /^(.*)\/creator\/enter\?id=([0-9A-Za-z]*)$/
    assert m = regex.match(@response.redirect_url)
    kid = m[2]
    assert_equal 6, kid.size
    forked_kata = katas[kid]
    assert forked_kata.exists?
    assert_equal 1, forked_kata.schema.version, :latest_version
    assert_equal kata.manifest.image_name, forked_kata.manifest.image_name
  end

  # . . . . . . . . . . . . .

  test 'P9w', %w( JSON: fork_group(id,index=-1) forks from latest index ) do
    id = '5rTJv5'
    kata = katas[id]
    assert kata.exists?
    assert_equal 0, kata.schema.version

    fork_group(:json, id , -1)

    assert forked?
    forked_group = groups[json['id']]
    assert forked_group.exists?
    assert_equal 1, forked_group.schema.version, :latest_version
    assert_equal kata.manifest.image_name, forked_group.manifest.image_name
  end

  # . . . . . . . . . . . . .

  test 'P9x', %w( HTML: fork_group(id,index=-1) forks from latest index ) do
    id = '5rTJv5'
    kata = katas[id]
    assert kata.exists?
    assert_equal 0, kata.schema.version

    fork_group(:html, id , -1)

    assert_response :redirect
    regex = /^(.*)\/creator\/enter\?id=([0-9A-Za-z]*)$/
    assert m = regex.match(@response.redirect_url)
    gid = m[2]
    assert_equal 6, gid.size
    forked_group = groups[gid]
    assert forked_group.exists?
    assert_equal 1, forked_group.schema.version, :latest_version
    assert_equal kata.manifest.image_name, forked_group.manifest.image_name
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Behaviour on bad arguments...

  test 'AF2', %w( when id is malformed the fork fails ) do
    fork_individual(:json, malformed_id = 'bad-id', index=1)
    refute forked?
  end

  test 'AF3', %w( when id does not exist the fork fails ) do
    fork_individual(:json, id = '112233', index=1)
    refute forked?
  end

  test 'AF4', %w( when tag is bad the fork fails ) do
    in_kata { |kata|
      fork_individual(:json, kata.id, index=1)
      refute forked?
      fork_individual(:json, kata.id, index=-34)
      refute forked?
      fork_individual(:json, kata.id, index=27)
      refute forked?
    }
  end

  private

  def fork_individual(format, id, index)
    post "/forker/fork_individual?id=#{id}&index=#{index}", params: { format:format }
  end

  def fork_group(format, id, index)
    post "/forker/fork_group?id=#{id}&index=#{index}", params: { format:format }
  end

  def forked?
    refute_nil json
    json['forked']
  end

end
