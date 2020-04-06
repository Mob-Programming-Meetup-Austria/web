# frozen_string_literal: true

require_relative 'id_generator'
require_relative 'id_pather'
require_relative 'kata_v1'
require_relative '../../lib/oj_adapter'

# 1. Manifest now has explicit version (1)
# 2. joined() now does 1 read, not 64 reads.
# 3. No longer stores JSON in pretty format.
# 4. No longer stores file contents in lined format.
# 5. Uses Oj as its JSON gem.

class Group_v1

  def initialize(externals)
    @kata = Kata_v1.new(externals)
    @externals = externals
  end

  # - - - - - - - - - - - - - - - - - - -

  def create(manifest)
    id = manifest['id'] = IdGenerator.new(@externals).group_id
    manifest['version'] = 1
    saver.batch_assert([
      manifest_write_cmd(id, json_plain(manifest)),
      katas_write_cmd(id, '')
    ])
    id
  end

  # - - - - - - - - - - - - - - - - - - -

  def manifest(id)
    manifest_src = saver.assert(manifest_read_cmd(id))
    json_parse(manifest_src)
  end

  # - - - - - - - - - - - - - - - - - - -

  def join(id, indexes)
    manifest = self.manifest(id)
    manifest.delete('id')
    manifest['group_id'] = id
    commands = indexes.map{ |index| create_cmd(id, index) }
    results = saver.batch_until_true(commands)
    result_index = results.find_index(true)
    if result_index.nil?
      nil # full
    else
      index = indexes[result_index]
      manifest['group_index'] = index
      kata_id = @kata.create(manifest)
      saver.assert(katas_append_cmd(id, "#{kata_id} #{index}\n"))
      kata_id
    end
  end

  # - - - - - - - - - - - - - - - - - - -

  def joined(id)
    katas_ids(katas_indexes(id))
  end

  # - - - - - - - - - - - - - - - - - - -

  def events(id)
    result = {}
    kindexes = katas_indexes(id)
    read_events_files_commands = katas_ids(kindexes).map do |kata_id|
      @kata.send(:events_read_cmd, kata_id)
    end
    katas_events = saver.batch_assert(read_events_files_commands)
    kindexes.each.with_index(0) do |(kata_id,kata_index),index|
      result[kata_id] = {
        'index' => kata_index,
        'events' => json_parse('[' + katas_events[index] + ']')
      }
    end
    result
  end

  private

  include IdPather
  include OjAdapter

  # - - - - - - - - - - - - - - - - - - - - - -

  def katas_ids(katas_indexes)
    katas_indexes.map{ |kata_id,_| kata_id }
  end

  # - - - - - - - - - - - - - - - - - - -

  def katas_indexes(id)
    katas_src = saver.assert(katas_read_cmd(id))
    # G2ws77 15
    # w34rd5 2
    # ...
    katas_src
      .split
      .each_slice(2)
      .map{|kid,kindex| [kid,kindex.to_i] }
      .sort{|lhs,rhs| lhs[1] <=> rhs[1] }
    # [
    #   ['w34rd5', 2], #  2 == bat
    #   ['G2ws77',15], # 15 == fox
    #   ...
    # ]
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def create_cmd(id, *parts)
    ['create', id_path(id, *parts)]
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def manifest_write_cmd(id, manifest_src)
    ['write', manifest_filename(id), manifest_src]
  end

  def manifest_read_cmd(id)
    ['read', manifest_filename(id)]
  end

  def manifest_filename(id)
    id_path(id, 'manifest.json')
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def katas_write_cmd(id, src)
    ['write', katas_filename(id), src]
  end

  def katas_append_cmd(id, src)
    ['append', katas_filename(id), src]
  end

  def katas_read_cmd(id)
    ['read', katas_filename(id)]
  end

  def katas_filename(id)
    id_path(id, 'katas.txt')
  end

  # - - - - - - - - - - - - - -

  def id_path(id, *parts)
    group_id_path(id, *parts)
  end

  # - - - - - - - - - - - - - -

  def saver
    @externals.saver
  end

end
