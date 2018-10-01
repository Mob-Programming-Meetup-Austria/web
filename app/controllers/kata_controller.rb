require_relative '../../lib/string_cleaner'
require_relative '../../lib/time_now'

class KataController < ApplicationController

  def group
    @kata = kata # TODO: @group
  end

  def edit
    @id = id
    @kata = kata
    @avatar_name = avatar_name
    @title = 'test:' + @kata.short_id
  end

  def run_tests
    @id = id
    @avatar_name = avatar_name
    case runner_choice
    when 'stateless'
      runner.set_hostname_port_stateless
    when 'stateful'
      runner.set_hostname_port_stateful
    end

    incoming = params[:file_hashes_incoming]
    outgoing = params[:file_hashes_outgoing]
    delta = FileDeltaMaker.make_delta(incoming, outgoing)
    files = received_files

    stdout,stderr,status,
      @colour,
        @new_files,@deleted_files,@changed_files =
          *kata.run_tests(image_name, max_seconds, delta, files, hidden_filenames)

    lights = kata.ran_tests(files, time_now, stdout, stderr, @colour)

    @was_tag = lights.size == 1 ? 0 : lights[-2].number
    @now_tag = lights[-1].number
    respond_to do |format|
      format.js   { render layout: false }
      format.json { show_json }
    end
  end

  # - - - - - - - - - - - - - - - - - -

  def show_json
    # https://atom.io/packages/cyber-dojo
    render :json => {
      'visible_files' => avatar.visible_files,
             'avatar' => avatar.name,
         'csrf_token' => form_authenticity_token,
             'lights' => avatar.lights.map { |light| light.to_json }
    }
  end

  private

  include StringCleaner
  include TimeNow

  def received_files
    seen = {}
    (params[:file_content] || {}).each do |filename, content|
      # Important to ignore output as it's not a 'real' file
      unless filename == 'output'
        content = cleaned(content)
        # Cater for windows line endings from windows browser
        seen[filename] = content.gsub(/\r\n/, "\n")
      end
    end
    seen
  end

end
