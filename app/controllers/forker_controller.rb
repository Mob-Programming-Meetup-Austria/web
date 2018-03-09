
class ForkerController < ApplicationController

  def fork
    begin
      tag_visible_files = storer.tag_visible_files(id, avatar_name, tag)
      manifest = kata.fork_manifest(tag_visible_files)
      kata = katas.create_kata(manifest)
      result = {
              forked: true,
                  id: kata.id,
          image_name: kata.image_name,
        display_name: kata.display_name
      }
    rescue => caught
      result = fork_failed(caught)
    end

    respond_to do |format|
      format.json { render json: result }
      format.html { redirect_to controller: 'kata',
                                    action: 'individual',
                                        id: result[:id] }
    end
  end

  private # = = = = = = = = = = =

  def fork_failed(caught)
    result = { forked: false }
    case caught.message
      when 'invalid kata_id'
        result[:reason] = "dojo(#{id})"
      when 'invalid avatar_name'
        result[:reason] = "avatar(#{avatar_name})"
      when 'invalid tag'
        result[:reason] = "traffic_light(#{tag})"
      else
        raise caught
    end
    result
  end

end

