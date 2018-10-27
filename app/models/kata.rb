require_relative '../lib/file_delta_maker'
require_relative '../lib/hidden_file_remover'
require_relative '../../lib/cleaner'

class Kata

  def initialize(externals, id)
    @externals = externals
    @id = id
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def id
    @id
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def exists?
    saver.kata_exists?(id)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def group
    gid = manifest.group_id
    if gid
      Group.new(@externals, gid)
    else
      nil
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def avatar_name
    if group
      Avatars.names[manifest.group_index]
    else
      ''
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def run_tests(params)
    # run tests but don't save the results
    case params[:runner_choice]
    when 'stateless'
      runner.set_hostname_port_stateless
    when 'stateful'
      runner.set_hostname_port_stateful
    end

    incoming = params[:file_hashes_incoming]
    outgoing = params[:file_hashes_outgoing]
    output_filenames.each do |output_filename|
      incoming.delete(output_filename)
      outgoing.delete(output_filename)
    end
    delta = FileDeltaMaker.make_delta(incoming, outgoing)

    image_name = params[:image_name]
    max_seconds = params[:max_seconds].to_i
    files = cleaned_files(params[:file_content])
    output_filenames.each do |output_filename|
      files.delete(output_filename)
    end

    stdout,stderr,status,
      colour,
        new_files,deleted_files,changed_files =
          runner.run_cyber_dojo_sh(image_name, id, max_seconds, delta, files)

    # If the runner has created an 'output' file remove it
    # otherwise it interferes with the pseudo output-files.
    output_filenames.each do |output_filename|
      new_files.delete(output_filename)
    end

    hidden_filenames = JSON.parse(params[:hidden_filenames])
    remove_hidden_files(new_files, hidden_filenames)

    # ensure (saved) files reflect changes
    new_files.each     { |filename,content| files[filename] = content }
    deleted_files.each { |filename,_      | files.delete(filename)    }
    changed_files.each { |filename,content| files[filename] = content }

    [stdout,stderr,status,
     colour,
     files,new_files,deleted_files,changed_files
    ]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def ran_tests(index, files, at, stdout, stderr, status, colour)
    # save run_tests() results.
    saver.kata_ran_tests(id, index, files, at, stdout, stderr, status, colour)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def age
    # in seconds
    (most_recent_event.time - manifest.created).to_i
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

  def lights
    # currently all events are test-events,
    # except the first creation event.
    events.select(&:light?)
  end

  def active?
    # only active katas are show on the dashboard
    lights != []
  end

  def events
    @events ||= saver.kata_events(id)
    @events.map.with_index { |h,index|
      Event.new(@externals, self, h, index)
    }
  end

  def manifest
    @manifest ||= Manifest.new(saver.kata_manifest(id))
  end

  private

  include FileDeltaMaker
  include HiddenFileRemover
  include Cleaner

  def output_filenames
    %w( stdout stderr status )
  end

  def most_recent_event
    events.last
  end

  def saver
    @externals.saver
  end

  def runner
    @externals.runner
  end

end
