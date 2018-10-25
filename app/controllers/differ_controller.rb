
class DifferController < ApplicationController

  def diff
    # This currently returns tags that are traffic-lights.
    # This matches the default tag handling in the review-controller.
    # The review/diff dialog/page has been refactored so it
    # works when sent either just traffic-lights or the full set of tags.
    # It does not yet have a way to select between these two options.
    # However if it is sent the full set of tags it must drop tag zero
    # (which is the _kata_ creation time). This is partly so that
    # the lowest tag.number is 1 (one) and not 0 (zero) as it is not
    # clear how to cleanly handle a tag of zero in diff-mode since it does
    # not have a previous tag. It is also partly because it makes sense
    # for the tags to correspond to actual kata/edit events.
    # So, in summary, if returning all the tags you still need to do a
    #         tags.shift

    @kata = kata
    tags = @kata.lights.map{ |light| to_json(light) }
    was_tag, now_tag = *was_now(tags)
    diff = differ.diff(@kata.id, was_tag, now_tag)
    view = diff_view(diff)
    prev_kata_id, next_kata_id = *ring_prev_next(@kata)
    render json: {
                         id: @kata.id,
                     avatar: @kata.avatar_name,
                     wasTag: was_tag,
                     nowTag: now_tag,
                       tags: tags,
                      diffs: view,
                 prevKataId: prev_kata_id,
                 nextKataId: next_kata_id,
	      idsAndSectionCounts: prune(view),
          currentFilenameId: pick_file_id(view, current_filename),
	  }
  end

  private

  include DiffView
  include RingPicker
  include ReviewFilePicker

  def was_now(tags)
    # You only get -1 when in non-diff mode and you switch to a
    # new avatar in which case was_tag==-1 and now_tag==-1
    was = number_or_nil(params[:was_tag])
    now = number_or_nil(params[:now_tag])
    was = tags[-1]['number'] if was == -1
    now = tags[-1]['number'] if now == -1
    [was,now]
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def current_filename
    params[:filename]
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def prune(array)
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
      'number' => light.number
    }
  end

end
