# frozen_string_literal: true
require_relative 'group'
require_relative 'id_pather'
require_relative 'manifest'
require_relative 'runner'
require_relative 'schema'
require_relative 'version'

class Kata

  def initialize(externals, params)
    @externals = externals
    @params = params
  end

  def id
    @params[:id]
  end

  def exists?
    IdGenerator.id?(id) &&
      saver.run(saver.dir_exists_command(kata_id_path(id)))
  end

  # - - - - - - - - - - - - - - - - -

  def schema
    @schema ||= Schema.new(@externals, kata_version)
  end

  def group?
    group_id
  end

  def group
    # NullObject pattern if group_id.nil?
    Group.new(@externals, @params.merge({id:group_id}))
  end

  def avatar_index
    # if this kata is inside a group, the kata's index in the group
    # (which is used to determine its avatar), else nil
    manifest.group_index
  end

  def run_tests(params = @params)
    Runner.new(@externals).run(params)
  end

  def events
    kata.events(id).map.with_index do |h,index|
      h['index'] ||= index
      Event.new(self, h)
    end
  end

  def events_json
    kata.events_json(id)
  end

  def event(index)
    kata.event(id, index)
  end

  def lights
    events.select(&:light?)
  end

  def active?
    lights != []
  end

  def age_f
    created = Time.mktime(*manifest.created)
    (most_recent_event.time.to_f - created.to_f)
  end

  def age
    age_f.to_i # seconds
  end

  def files
    most_recent_event.files
  end

  def stdout
    most_recent_event.stdout
  end

  def stderr
    most_recent_event.stderr
  end

  def status
    most_recent_event.status
  end

  # - - - - - - - - - - - - - - - - -

  def theme=(value)
    # value == 'dark'|'light'
    filename = kata_id_path(id, 'theme')
    # There is no file-write command (yet)
    saver.run_all([
      saver.file_create_command(filename, "\n"+value),
      saver.file_append_command(filename, "\n"+value)
    ])
  end

  def theme
    filename = kata_id_path(id, 'theme')
    result = saver.run(saver.file_read_command(filename))
    if result
      result.lines.last
    else
      'light' # default, better on projectors (other option is 'dark')
    end
  end

  # - - - - - - - - - - - - - - - - -

  def colour=(value)
    # value == 'on'|'off'
    filename = kata_id_path(id, 'colour')
    # There is no file-write command (yet)
    saver.run_all([
      saver.file_create_command(filename, "\n"+value),
      saver.file_append_command(filename, "\n"+value)
    ])
  end

  def colour
    filename = kata_id_path(id, 'colour')
    result = saver.run(saver.file_read_command(filename))
    if result
      result.lines.last
    else
      'on' # default (other option is 'off')
    end
  end

  # - - - - - - - - - - - - - - - - -

  def predict
    filename = kata_id_path(id, 'predict')
    result = saver.run(saver.file_read_command(filename))
    if result
      result.lines.last
    else
      'off' # default (other options in 'on')
    end
  end

  def predict=(value)
    # value == 'on'|'off'
    filename = kata_id_path(id, 'predict')
    # There is no file-write command (yet)
    saver.run_all([
      saver.file_create_command(filename, "\n"+value),
      saver.file_append_command(filename, "\n"+value)
    ])
  end

  # - - - - - - - - - - - - - - - - -

  def manifest
    @manifest ||= Manifest.new(kata.manifest(id))
  end

  private

  include IdPather
  include Version

  def plain(files)
    files.map{ |filename,file| [filename, file['content']] }.to_h
  end

  # - - - - - - - - - - - - - - - - -

  def group_id
    manifest.group_id # nil if not in a group
  end

  def kata
    schema.kata
  end

  def most_recent_event
    events.last
  end

  def model
    @externals.model
  end

  def saver
    @externals.saver
  end

  def model
    @externals.model
  end

end
