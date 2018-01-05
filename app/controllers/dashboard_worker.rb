require_relative '../../lib/time_now' # [1]

module DashboardWorker # mixin

  module_function

  def gather
    @kata = kata
    @minute_columns = bool('minute_columns')
    @auto_refresh = bool('auto_refresh')

    @all_lights = {}
    storer.kata_increments(kata.id).each do |name, lights|
      lights.shift # 0==created-event
      unless lights.empty?
        @all_lights[name] = lights
      end
    end

    max_seconds_uncollapsed = seconds_per_column * 5
    args = []
    args << kata.created
    args << seconds_per_column
    args << max_seconds_uncollapsed
    gapper = DashboardTdGapper.new(*args)

    @gapped = gapper.fully_gapped(@all_lights, time_now)
    @time_ticks = gapper.time_ticks(@gapped)
  end

  include TimeNow

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

  def animals_progress
    animals = {}
    avatars.active.each do |avatar|
      animals[avatar.name] = {
          colour: avatar.lights[-1].colour,
        progress: most_recent_progress(avatar)
      }
    end
    animals
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def most_recent_progress(avatar)
    regexs = avatar.kata.progress_regexs
    non_amber = avatar.lights.reverse.find{ |light|
      [:red,:green].include?(light.colour)
    }
    output = (non_amber != nil) ? non_amber.output : ''
    matches = regexs.map { |regex|
      Regexp.new(regex).match(output)
    }
    return {
        text: matches.join,
      colour: (matches[0] != nil ? 'red' : 'green')
    }
  end

end

# [1] I see the occasional
# ActionController::RoutingError (uninitialized constant DashboardWorker::TimeNow):
# in the log unless I add this require
