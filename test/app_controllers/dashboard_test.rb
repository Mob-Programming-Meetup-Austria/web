require_relative 'app_controller_test_base'

class DashboardControllerTest < AppControllerTestBase

  def self.hex_prefix
    '62AB98'
  end

  #- - - - - - - - - - - - - - - -

  test '971', %w( minute_column/auto_refresh true/false ) do
    in_kata(:stateless) {}
    options = [ false, true, 'xxx' ]
    options.each do |mc|
      options.each do |ar|
        dashboard minute_columns: mc, auto_refresh: ar
      end
    end
  end

  #- - - - - - - - - - - - - - - -

  test 'E43', %w(
  with and without avatars, and
  with and without traffic lights ) do
    in_kata('Java, JUnit') {
      # no avatars
      dashboard
      heartbeat
      progress
      # some avatars
      3.times {
        assert_join
        # no traffic-lights
        dashboard
        heartbeat
        progress
        # some traffic-lights
        2.times {
          run_tests
        }
      }
      dashboard
      heartbeat
      progress
    }
  end

  private # = = = = = = = = = = = = = =

  def dashboard(params = {})
    params[:id] = @id
    get '/dashboard/show', params:params
    assert_response :success
  end

  def heartbeat
    params = { :format => :js, :id => @id }
    get '/dashboard/heartbeat', params:params
    assert_response :success
  end

  def progress
    params = { :format => :js, :id => @id }
    get '/dashboard/progress', params:params
    assert_response :success
  end

end
