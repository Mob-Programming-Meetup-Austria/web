
module DashboardWorker # mixin

  module_function

  def gather
    names = Avatars.names
    @minute_columns = bool('minute_columns')
    @auto_refresh = bool('auto_refresh')
    @all_lights = {}
    @all_indexes = {}
#puts "A:#{saver.log.size}"   49
    e = group.events
#puts "B:#{saver.log.size}"   51
    e.each do |kata_id,o|
      lights = o['events'].each_with_index.map{ |event,index|
        Event.new(katas[kata_id], event, index)
      }.select(&:light?)
      unless lights === []
        @all_lights[kata_id] = lights
        @all_indexes[kata_id] = o['index']
      end
    end
#puts "C:#{saver.log.size}"  51
    args = [group.created, seconds_per_column, max_seconds_uncollapsed]
#puts "D:#{saver.log.size}"  52
    gapper = DashboardTdGapper.new(*args)
    @gapped = gapper.fully_gapped(@all_lights, time.now)
    @time_ticks = gapper.time_ticks(@gapped)
#puts "E:#{saver.log.size}"  52
    @age = group.age(e)
#puts "F:#{saver.log.size}"  52
    set_footer_info
#puts "G:#{saver.log.size}"  52
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def set_footer_info
    @id = group.id
    @display_name = group.manifest.display_name
    @exercise = group.manifest.exercise
  end

  def bool(attribute)
    tf = params[attribute]
    (tf == 'false') ? tf : 'true'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def seconds_per_column
    flag = params['minute_columns']
    # default is that time-gaps are on
    return 60 if flag.nil? || flag == 'true'
    return 60*60*24*365*1000
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def max_seconds_uncollapsed
    seconds_per_column * 5
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def animals_progress
    group.katas
         .select(&:active?)
         .map { |kata| animal_progress(kata) }
         .to_h
  end

  def animal_progress(kata)
    [kata.avatar_name, {
        colour: kata.lights[-1].colour,
      progress: most_recent_progress(kata),
         index: Avatars.index(kata.avatar_name)
    }]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def most_recent_progress(kata)
    regexs = kata.manifest.progress_regexs
    non_amber = kata.lights.reverse.find{ |light|
      [:red,:green].include?(light.colour)
    }
    if non_amber
      output = non_amber.stdout['content'] + non_amber.stderr['content']
    else
      output = ''
    end
    matches = regexs.map { |regex|
      Regexp.new(regex).match(output)
    }
    {
        text: matches.join,
      colour: (matches[0] != nil ? 'red' : 'green')
    }
  end

end
