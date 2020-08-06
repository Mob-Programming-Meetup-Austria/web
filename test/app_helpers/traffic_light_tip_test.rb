require_relative 'app_helpers_test_base'

class TipTest < AppHelpersTestBase

  def self.hex_prefix
    'Qd4'
  end

  include TrafficLightTipHelper

  v_tests [0,1], 'D52',
  'traffic-light tip for individual kata does not have avatar-image' do
    in_new_kata do |kata|
      files = kata.files
      stdout = file("Expected: 42\nActual: 54")
      stderr = file('assert failed')
      status = 4
      kata.ran_tests(1, files, time.now, duration, stdout, stderr, status, 'red')

      filename = 'hiker.rb'
      hiker_rb = kata.files[filename]['content']
      files[filename] = file(hiker_rb.sub('6 * 9','6 * 7'))
      stdout = file('All tests passed')
      stderr = file('')
      status = 0
      kata.ran_tests(2, files, time.now, duration, stdout, stderr, status, 'green')

      events = kata.events
      was_files = files_for(events, 1)
      now_files = files_for(events, now_index=2)
      diff = differ.diff(kata.id, was_files, now_files)
      number = 2

      expected =
        '<table>' +
          '<tr>' +
            "<td><span class='traffic-light-count green'>#{number}</span></td>" +
            "<td><img src='/traffic-light/image/green_predicted_none.png' class='traffic-light-diff-tip-traffic-light-image'></td>" +
          '</tr>' +
        '</table>' +
        '<table>' +
          '<tr>' +
            "<td><div class='traffic-light-diff-tip-line-count-deleted some button'>1</div></td>" +
            "<td><div class='traffic-light-diff-tip-line-count-added some button'>1</div></td>" +
            "<td>&nbsp;hiker.rb</td>" +
          '</tr>' +
        '</table>'

      actual = traffic_light_tip_html(diff, kata.avatar_index, events, now_index, number)
      assert_equal expected, actual
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  v_tests [0,1], 'D53',
  'traffic-light tip for kata in a group has an avatar-image' do
    in_new_group do |group|
      kata = group.join
      files = kata.files
      stdout = file("Expected: 42\nActual: 54")
      stderr = file('assert failed')
      status = 4
      kata.ran_tests(1, files, time.now, duration, stdout, stderr, status, 'red')

      filename = 'hiker.rb'
      hiker_rb = kata.files[filename]['content']
      files[filename] = file(hiker_rb.sub('6 * 9','6 * 7'))
      stdout = file('All tests passed')
      stderr = file('')
      status = 0
      kata.ran_tests(2, files, time.now, duration, stdout, stderr, status, 'green')

      events = kata.events
      was_files = files_for(events, 1)
      now_files = files_for(events, now_index=2)
      diff = differ.diff(kata.id, was_files, now_files)
      number = 2

      expected =
        '<table>' +
          '<tr>' +
            "<td><img src='/avatar/image/#{kata.avatar_index}' class='traffic-light-diff-tip-avatar-image'></td>" +
            "<td><span class='traffic-light-count green'>#{number}</span></td>" +
            "<td><img src='/traffic-light/image/green_predicted_none.png' class='traffic-light-diff-tip-traffic-light-image'></td>" +
          '</tr>' +
        '</table>' +
        '<table>' +
          '<tr>' +
            "<td><div class='traffic-light-diff-tip-line-count-deleted some button'>1</div></td>" +
            "<td><div class='traffic-light-diff-tip-line-count-added some button'>1</div></td>" +
            "<td>&nbsp;hiker.rb</td>" +
          '</tr>' +
        '</table>'

      actual = traffic_light_tip_html(diff, kata.avatar_index, events, now_index, number)
      assert_equal expected, actual
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  v_tests [0,1], 'D54',
  'traffic-light tip for creation event (index==0)' do
    in_new_group do |group|
      kata = group.join
      files = kata.files
      stdout = file("Expected: 42\nActual: 54")
      stderr = file('assert failed')
      status = 4
      kata.ran_tests(1, files, time.now, duration, stdout, stderr, status, 'red')
      events = kata.events
      was_files = files_for(events, was_index=0)
      now_files = files_for(events, now_index=0)
      diff = differ.diff(kata.id, was_files, now_files)
      number = 2
      actual = traffic_light_tip_html(diff, kata.avatar_index, events, now_index, number)
      assert actual.include?("src='/avatar/image/"), actual+':'+actual.class.name+':'
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  v_tests [0,1], 'D55',
  'traffic-light tip for faulty event' do
    in_new_kata do |kata|
      files = kata.files
      stdout = file("Expected: 42\nActual: 54")
      stderr = file('assert failed')
      status = 4
      kata.ran_tests(was_index=1, files, time.now, duration, stdout, stderr, status, 'red')

      filename = 'hiker.rb'
      hiker_rb = kata.files[filename]['content']
      files[filename] = file(hiker_rb.sub('6 * 9','6 * 7'))
      stdout = file('All tests passed')
      stderr = file('')
      status = 0
      kata.ran_tests(now_index=2, files, time.now, duration, stdout, stderr, status, 'faulty')

      events = kata.events
      was_files = files_for(events, was_index)
      now_files = files_for(events, now_index)
      diff = differ.diff(kata.id, was_files, now_files)
      number = 2

      expected =
        '<table>' +
          '<tr>' +
            "<td><span class='traffic-light-count faulty'>#{number}</span></td>" +
            "<td><img src='/traffic-light/image/faulty.png' class='traffic-light-diff-tip-traffic-light-image'></td>" +
          '</tr>' +
        '</table>' +
        '<table>' +
          '<tr>' +
            "<td><div class='traffic-light-diff-tip-line-count-deleted some button'>1</div></td>" +
            "<td><div class='traffic-light-diff-tip-line-count-added some button'>1</div></td>" +
            "<td>&nbsp;hiker.rb</td>" +
          '</tr>' +
        '</table>'

      actual = traffic_light_tip_html(diff, kata.avatar_index, events, now_index, number)
      assert_equal expected, actual
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  v_tests [0,1], 'D56', %w(
  traffic-light tip for incorrect prediction
  ) do
    in_new_kata do |kata|
      files = kata.files
      stdout = file("Expected: 42\nActual: 54")
      stderr = file('assert failed')
      status = 4
      kata.ran_tests(1, files, time.now, duration, stdout, stderr, status, 'red')

      filename = 'hiker.rb'
      hiker_rb = kata.files[filename]['content']
      files[filename] = file(hiker_rb.sub('6 * 9','6 * 7'))
      stdout = file('All tests passed')
      stderr = file('')
      status = 0
      predicted = 'red'
      kata.ran_tests(2, files, time.now, duration, stdout, stderr, status, 'green', predicted)

      events = kata.events
      was_files = files_for(events, 1)
      now_files = files_for(events, now_index=2)
      diff = differ.diff(kata.id, was_files, now_files)
      number = 2

      expected =
        '<table>' +
          '<tr>' +
            "<td><span class='traffic-light-count green'>#{number}</span></td>" +
            "<td><img src='/traffic-light/image/green_predicted_red.png' class='traffic-light-diff-tip-traffic-light-image'></td>" +
          '</tr>' +
        '</table>' +
        '<table>' +
          '<tr>' +
            "<td><div class='traffic-light-diff-tip-line-count-deleted some button'>1</div></td>" +
            "<td><div class='traffic-light-diff-tip-line-count-added some button'>1</div></td>" +
            "<td>&nbsp;hiker.rb</td>" +
          '</tr>' +
        '</table>'

      actual = traffic_light_tip_html(diff, kata.avatar_index, events, now_index, number)
      assert_equal expected, actual
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  v_tests [0,1], 'D57', %w(
  traffic-light tip for revert
  ) do
    in_new_kata do |kata|
      files = kata.files
      stdout_1 = file("Expected: 42\nActual: 54")
      stderr_1 = file('assert failed')
      status_1 = 4
      kata.ran_tests(1, files, time.now, duration, stdout_1, stderr_1, status_1, 'red')

      filename = 'hiker.rb'
      hiker_rb = kata.files[filename]['content']
      files[filename] = file(hiker_rb.sub('6 * 9','6 * 7'))
      stdout_2 = file('All tests passed')
      stderr_2 = file('')
      status_2 = 0
      kata.ran_tests(2, files, time.now, duration, stdout_2, stderr_2, status_2, 'green')

      kata.revert(3, kata.events[1].files, time.now, stdout_1, stderr_1, status_1, 'red', 1)

      events = kata.events
      was_files = files_for(events, 2)
      now_files = files_for(events, 3)
      diff = differ.diff(kata.id, was_files, now_files)
      number = 3

      expected =
        '<table>' +
          '<tr>' +
            "<td><span class='traffic-light-count red'>#{number}</span></td>" +
            "<td><img src='/traffic-light/image/red_revert.png' class='traffic-light-diff-tip-traffic-light-image'></td>" +
          '</tr>' +
        '</table>' +
        '<table>' +
          '<tr>' +
            "<td><div class='traffic-light-diff-tip-line-count-deleted some button'>1</div></td>" +
            "<td><div class='traffic-light-diff-tip-line-count-added some button'>1</div></td>" +
            "<td>&nbsp;hiker.rb</td>" +
          '</tr>' +
        '</table>'

      actual = traffic_light_tip_html(diff, kata.avatar_index, events, 3, number)
      assert_equal expected, actual
    end
  end

  private

  def files_for(events, index)
    events[index].files
                 .map{ |filename,file| [filename, file['content']] }
                 .to_h
  end

  def file(content)
    { 'content' => content,
      'truncated' => false
    }
  end

end
