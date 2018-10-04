require_relative '../../lib/time_now'

class KataController < ApplicationController

  def group
    @id = id
  end

  def edit
    @id = id
    @kata = kata
    @avatar_name = avatar_name
    @title = 'test:' + partial(@kata.id)
  end

  def run_tests
    # After a test-event completes if you refresh the
    # page in the browser then nothing will change.
    @id = id
    @avatar_name = avatar_name

    stdout,stderr,status,
      @colour,
        files,@new_files,@deleted_files,@changed_files = kata.run_tests(params)

    lights = kata.ran_tests(files, time_now, stdout, stderr, status, @colour)

    @was_tag = lights.size == 1 ? 0 : lights[-2].number
    @now_tag = lights[-1].number
    respond_to do |format|
      format.js   { render layout: false }
      format.json { show_json }
    end
  end

  def show_json
    # https://atom.io/packages/cyber-dojo
    render :json => {
      'visible_files' => kata.files,
             'avatar' => avatar_name,
         'csrf_token' => form_authenticity_token,
             'lights' => kata.lights.map { |light| to_json(light) }
    }
  end

  private

  include TimeNow

  def to_json(light)
    {
      'colour' => light.colour,
      'time'   => light.time,
      'number' => light.number
    }
  end

end
