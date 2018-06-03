
module TipHelper # mix-in

  def traffic_light_tip_html(diffs, avatar, was_tag, now_tag)
    was_tag = was_tag.to_i
    now_tag = now_tag.to_i
    tags = avatar.tags

    tip = '<table><tr>'
    tip += td(traffic_light_img(tags, was_tag))  # rag
    tip += td(colour_tag_html(tags, was_tag))    # 13
    tip += td(right_arrow)                       # ->
    tip += td(traffic_light_img(tags, now_tag))  # rag
    tip += td(colour_tag_html(tags, now_tag))    # 14
    tip += td(avatar_img(avatar.name))           # panda
    tip += '</tr></table>'

    tip += '<table>'
    diffs.each do |filename, diff|
      added   = diff.count { |line| line['type'] == 'added'   }
      deleted = diff.count { |line| line['type'] == 'deleted' }
      if filename != 'output' && (added + deleted != 0)
        tip += '<tr>'
        tip += td(diff_count('deleted', deleted))
        tip += td(diff_count('added', added))
        tip += td('&nbsp;' + filename)
        tip += '</tr>'
      end
    end
    tip += '</table>'
  end

  module_function

  def colour_tag_html(tags, tag_number)
    colour = (tag_number == 0) ? 'none' : tag_colour(tags, tag_number)
    "<span class='traffic-light-diff-tip-tag #{colour}'>#{tag_number}</span>"
  end

  def traffic_light_img(tags, tag_number)
    return '' if tag_number == 0
    colour = tag_colour(tags, tag_number)
    "<img src='/images/bulb_#{colour}.png' class='traffic-light-diff-tip-traffic-light-image'>"
  end

  def tag_colour(tags, tag_number)
    tags[tag_number].colour
  end

  def right_arrow
    '<div>&rarr;</div>'
  end

  def avatar_img(avatar)
    "<img src='/images/avatars/#{avatar}.jpg' class='traffic-light-diff-tip-avatar-image'>"
  end

  def diff_count(name, count)
    "<div class='traffic-light-diff-tip-line-count-#{name} some button'>#{count}</div>"
  end

  def td(text)
    '<td>' + text + '</td>'
  end

end
