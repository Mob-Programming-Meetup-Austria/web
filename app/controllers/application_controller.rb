require_relative '../helpers/phonetic_helper'
require 'json'

class ApplicationController < ActionController::Base

  protect_from_forgery

  include Externals
  include PhoneticHelper

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def ported
    # See comment below
    if id.size == 10
      id6 = porter.port(id)
      url = request.url
      if m = /#{id}\?avatar=([a-z]*)&?/.match(url)
        kata = groups[id6].katas.find{ |k| k.avatar_name == m[1] }
        url6 = url.sub(m.to_s, kata.id+'?')
      else
        url6 = url.sub(id, id6)
      end
      url6 = url6.sub('was_tag', 'was_index')
      url6 = url6.sub('now_tag', 'now_index')
      redirect_to url6
    else
      yield
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def groups
    Groups.new(self)
  end

  def group
    @group ||= groups[id]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def katas
    Katas.new(self)
  end

  def kata
    @kata ||= katas[id]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def was_files
    files_for(was_index)
  end

  def now_files
    files_for(now_index)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def was_index
    was = params[:was_index].to_i
    if was == -1
      was = kata.events.size - 1
    end
    was
  end

  def now_index
    now = params[:now_index].to_i
    if now == -1
      now = kata.events.size - 1
    end
    now
  end

  def index
    params[:index].to_i
  end

  def id
    params[:id]
  end

  def files_for(index)
    kata.events[index]
        .files(:with_output)
        .map{ |filename,file| [filename, file['content']] }
        .to_h
  end

end

# - - - - - - - - - - - - - - - - - - - - - - - -
# ported()
# - - - - - - - - - - - - - - - - - - - - - - - -
# cyber-dojo is designed for group practice-sessions.
# In this 'mode' URLs used to look like this...
#    http://cyber-dojo.org/kata/edit/hVU93Kj8rq?avatar=tiger
# The hVU93Kj8rq was a 10-digit group-id
# and the avatar=tiger was your animal inside this group.
# Now, ported() will redirect these URLs to, eg...
#    http://cyber-dojo.org/kata/edit/mFL6se
# where mFL6se is the 6-digit kata-id
# and the associated avatar-name is _not_ part of the URL.
#
# cyber-dojo can also be used for individual practice-sessions.
# In this 'mode' URLs also look like this...
#   http://cyber-dojo.org/kata/edit/ym04AU
# The ym04AU is a 6-digit kata-id
# and there is no associated avatar-name.
#
# Examples of ported() URL redirections...
#
#     dashboard/show/1F00C1BFC8
# --> dashboard/show/2M0Ry7?
#
#     kata/edit/1F00C1BFC8?avatar=turtle
# --> kata/edit/2M0Ry7?
#
#     review/show/1F00C1BFC8?avatar=turtle&was_tag=2&now_tag=3
# --> review/show/2M0Ry7?was_tag=2&now_tag=3
# --> review/show/2M0Ry7?was_index=2&now_index=3
# - - - - - - - - - - - - - - - - - - - - - - - -
