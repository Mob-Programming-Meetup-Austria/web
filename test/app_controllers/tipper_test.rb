require_relative 'app_controller_test_base'

class TipperControllerTest < AppControllerTestBase

  def self.hex_prefix
    '25E'
  end

  # - - - - - - - - - - - - - - - - - -

  test '3D4',
  'traffic_light_tip' do
    in_kata {
      2.times {
        post_run_tests
      }
    }
    count_before = saver.log.size
    get '/tipper/traffic_light_tip', params: {
      'format'    => 'js',
      'id'        => kata.id,
      'was_index' => 0,
      'now_index' => 1
    }
    assert_response :success
    count_after = saver.log.size
    #puts [count_before,count_after] # [22,29]
    assert_equal 7, (count_after-count_before)
  end

end
