require_relative 'app_helpers_test_base'
require 'ostruct'

class TrafficLightTest < AppHelpersTestBase

  def self.hex_prefix
    'Hf6'
  end

  include TrafficLightHelper

  #- - - - - - - - - - - - - - - -

  test '67C',
  'traffic_light_count' do
    lights = [
      event(0, colour:'red'  , predicted:'none'),
      event(1, colour:'red'  , predicted:'none'),
      event(2, colour:'amber', predicted:'none'),
      event(3, colour:'green', predicted:'none'),
      event(4, colour:'amber', predicted:'none'),
    ]
    expected =
      "<div class='traffic-light-count-wrapper'>" +
        "<div class='traffic-light-count amber'" +
            " data-tip='traffic_light_count'" +
            " data-red-count='2'" +
            " data-amber-count='2'" +
            " data-green-count='1'" +
            " data-timed-out-count='0'>" +
          "5" +
        "</div>" +
      "</div>"
    actual = traffic_light_count(lights)
    assert_equal expected, actual
  end

  #- - - - - - - - - - - - - - - -

  test 'E41', %w(
  traffic_light_image has
  prediction for red|amber|green
  but not for faulty|timed_out
  ) do
    red = event(0, colour:'red')
    expected_red = "<img src='/traffic-light/image/red_predicted_none.png'" +
                   " alt='red traffic-light'/>"
    assert_equal expected_red, traffic_light_image(red)

    amber = event(1, colour:'amber')
    expected_amber = "<img src='/traffic-light/image/amber_predicted_none.png'" +
                     " alt='amber traffic-light'/>"
    assert_equal expected_amber, traffic_light_image(amber)

    green = event(2, colour:'green')
    expected_green = "<img src='/traffic-light/image/green_predicted_none.png'" +
                     " alt='green traffic-light'/>"
    assert_equal expected_green, traffic_light_image(green)

    faulty = event(3, colour:'faulty')
    expected_faulty = "<img src='/traffic-light/image/faulty.png'" +
                      " alt='faulty traffic-light'/>"
    assert_equal expected_faulty, traffic_light_image(faulty)

    timed_out = event(4, colour:'timed_out')
    expected_timed_out = "<img src='/traffic-light/image/timed_out.png'" +
                         " alt='timed_out traffic-light'/>"
    assert_equal expected_timed_out, traffic_light_image(timed_out)
  end

  #- - - - - - - - - - - - - - - -

  test '443',
  'diff_traffic_light' do
    id = 'a4r9YN'
    kata = OpenStruct.new(id:id)
    light = event(index=14, colour:'green', predicted:'none', kata:kata)
    number = 15
    avatar_index = 37
    expected = '' +
      "<div class='diff-traffic-light'" +
        " data-id='#{id}'" +
        " data-index='#{index}'" +
        " data-number='#{number}'" +
        " data-avatar-index='#{avatar_index}'" +
        " data-colour='green'>" +
        "<img src='/traffic-light/image/green_predicted_none.png'" +
           " alt='green traffic-light'/>" +
      '</div>'
    actual = diff_traffic_light(light, avatar_index, number)
    assert_equal expected, actual
  end

  #- - - - - - - - - - - - - - - -

  test '444',
  'reverted diff_traffic_light' do
    id = 'Lr5ebj'
    kata = OpenStruct.new(id:id)
    light = event(index=14, colour:'red', predicted:'none', kata:kata, revert:6)
    number = 15
    avatar_index = 37
    expected = '' +
      "<div class='diff-traffic-light'" +
        " data-id='#{id}'" +
        " data-index='#{index}'" +
        " data-number='#{number}'" +
        " data-avatar-index='#{avatar_index}'" +
        " data-colour='red'>" +
        "<img src='/traffic-light/image/red_revert.png'" +
           " alt='red traffic-light'/>" +
      '</div>'
    actual = diff_traffic_light(light, avatar_index, number)
    assert_equal expected, actual
  end

  private

  def event(index, args)
    summary = {
      'index' => index,
      'colour' => args[:colour],
      'predicted' => (args[:predicted] || 'none')
    }
    if args[:revert]
      summary['revert'] = args[:revert]
    end
    Event.new(args[:kata], summary)
  end

end
