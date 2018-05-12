require_relative '../../lib/phonetic_alphabet'
require_relative '../../lib/string_cleaner'
require_relative '../../lib/time_now'

class KataController < ApplicationController

  def individual
    @kata_id = kata.id
    @avatar_name = avatar.name
    @phonetic = Phonetic.spelling(kata.id[0..5])
  end

  def group
    @kata_id = kata.id
    @phonetic = Phonetic.spelling(kata.id[0..5])
  end

  def edit
    @kata = kata
    @avatar = avatar
    @visible_files = @avatar.visible_files
    @traffic_lights = @avatar.lights
    @output = @visible_files['output']
    @title = 'test:' + @kata.id[0..5] + ':' + @avatar.name
  end

  def run_tests
    incoming = params[:file_hashes_incoming]
    outgoing = params[:file_hashes_outgoing]
    delta = FileDeltaMaker.make_delta(incoming, outgoing)
    files = received_files

    @avatar = Avatar.new(self, kata, avatar_name)

    case runner_choice
    when 'stateless'
      runner.set_hostname_port_stateless
    when 'stateful'
      runner.set_hostname_port_stateful
    #when 'processful'
      #runner.set_hostname_port_processful
    end

    args = []
    args << delta
    args << files
    args << max_seconds # eg 10
    args << image_name  # eg 'cyberdojofoundation/gcc_assert'
    stdout,stderr,status,@colour,@new_files,@deleted_files = avatar.test(*args)

    if @colour == 'timed_out'
      stdout = timed_out_message(max_seconds) + stdout
    end

    # Storer's snapshot exactly mirrors the files after the test-event
    # has completed. That is, after a test-event completes if you
    # refresh the page in the browser then nothing changes.
    @deleted_files.keys.each do |filename|
      files.delete(filename)
    end
    # If there is a file called output remove it otherwise
    # it will interfere with the @output pseudo-file.
    @new_files.delete('output')
    @new_files.each do |filename,content|
      files[filename] = content
    end

    # avatar.tested() saves the test results to storer which
    # also validates a kata with the given id exists.
    # It could become a fire-and-forget method.
    # This might decrease run_tests() response time.
    # Also, I have tried to make it fire-and-forget using the
    # spawnling gem and it breaks a test in a non-obvious way.
    avatar.tested(files, time_now, stdout, stderr, @colour)

    @output = stdout + stderr

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

  private # = = = = = = = = = = = = = =

  include StringCleaner
  include TimeNow

  def received_files
    seen = {}
    (params[:file_content] || {}).each do |filename, content|
      content = cleaned(content)
      # Important to ignore output as it's not a 'real' file
      unless filename == 'output'
        # Cater for windows line endings from windows browser
        seen[filename] = content.gsub(/\r\n/, "\n")
      end
    end
    seen
  end

  def timed_out_message(max_seconds)
    [
      "Unable to complete the tests in #{max_seconds} seconds.",
      'Is there an accidental infinite loop?',
      'Is the server very busy?',
      'Please try again.'
    ].join("\n") + "\n"
  end

end
