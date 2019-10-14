
class DifferController < ApplicationController

  def info(letter)
    #puts "#{letter}:#{saver.log.size}"
  end

  def diff
    info('A') # 25
    old_files = was_files
    info('B') # 27
    new_files = now_files
    info('C') # 29
    # ensure stdout/stderr/status show no diff
    old_files['stdout'] = new_files['stdout']
    old_files['stderr'] = new_files['stderr']
    old_files['status'] = new_files['status']
    info('D')
    diff = differ.diff(kata.id, old_files, new_files)
    info('E')
    view = diff_view(diff)
    info('F') # 29
    exts = kata.manifest.filename_extension
    info('G') # 30
    render json: {
                    version: kata.schema.version,
                         id: kata.id,
                avatarIndex: kata.avatar_index,
                 avatarName: kata.avatar_name,
                   wasIndex: was_index,
                   nowIndex: now_index,
                     events: kata.events.map{ |event| to_json(event) },
                      diffs: view,
	      idsAndSectionCounts: pruned(view),
          currentFilenameId: pick_file_id(view, current_filename, exts)
	  }
  end

  def diff2
    version = params[:version].to_i
    id = params[:id]
    was_index = params[:was_index].to_i
    now_index = params[:now_index].to_i
    was_index,now_index,manifest,events,old_files,new_files = kata.diff_info(was_index, now_index)
    # ensure stdout/stderr/status show no diff
    old_files['stdout'] = new_files['stdout']
    old_files['stderr'] = new_files['stderr']
    old_files['status'] = new_files['status']
    diff = differ.diff(id, old_files, new_files)
    view = diff_view(diff)
    m = Manifest.new(manifest)
    exts = m.filename_extension
    avatar_index = m.group_index
    avatar_name = avatar_index ? Avatars.names[avatar_index] : ''
    result = {
                    version: version,
                         id: id,
                avatarIndex: avatar_index,
                 avatarName: avatar_name,
                   wasIndex: was_index,
                   nowIndex: now_index,
                     events: events.map{ |event| to_json(event) },
                      diffs: view,
	      idsAndSectionCounts: pruned(view),
          currentFilenameId: pick_file_id(view, current_filename, exts)
	  }
    render json:result
  end

  private

  include DiffView
  include ReviewFilePicker

  def current_filename
    params[:filename]
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def pruned(array)
    array.map { |hash| {
      :id            => hash[:id],
      :section_count => hash[:section_count]
    }}
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def to_json(light)
    {
      'colour' => light.colour,
      'time'   => light.time,
      'index'  => light.index
    }
  end

end
