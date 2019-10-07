require_relative 'app_controller_test_base'

class DashboardControllerTest < AppControllerTestBase

  def self.hex_prefix
    '62A'
  end

  #- - - - - - - - - - - - - - - -

  test '971', %w( minute_column/auto_refresh true/false ) do
    [0,1].each do |version|
      in_group(version:version) do |group|
        @gid = group.id
        @version = version
        options = [ false, true, 'xxx' ]
        options.each do |mc|
          options.each do |ar|
            dashboard(minute_columns:mc, auto_refresh:ar)
          end
        end
      end
    end
  end

  #- - - - - - - - - - - - - - - -

  test '972', %w( version 0 dashboard ) do
    set_saver_class('SaverService')
    @version = 0
    @gid = 'chy6BJ'
    dashboard
  end

  #- - - - - - - - - - - - - - - -

  test '973', %w(
  saver-service call efficiency
  ) do
    [0,1].each do |version|
      options = {
             version:version,
        display_name:'Python, unittest'
      }
      in_group(options) do |group|
        @gid = group.id
        @version = version
        2.times {
          kata = assert_join(@gid)
          @id = kata.id
          @files = plain(kata.files)
          @index = 0
          post_run_tests
          assert_equal 1, kata.lights.size
        }
        count_before = saver.log.size
        dashboard
        count_after = saver.log.size
        saver_call_count = count_after - count_before
        # 1 - find kata ids
        # 2 - get events for each kata (batch)
        # 3 - get manifest for group
        assert_equal 3, saver_call_count, [count_before,count_after]
        #tail = saver.log[-3..-1]
        #puts "tail:#{tail.inspect}"
        heartbeat
        progress
      end
    end
  end

  #- - - - - - - - - - - - - - - -

  test '974', %w(
  dashboard regex-progress
  ) do
    set_saver_class('SaverService')
    @gid = 'chy6BJ'
    @version = 0
    dashboard
    heartbeat
    progress
  end

  private # = = = = = = = = = = = = = =

  def dashboard(params = {})
    params[:id] = @gid
    params[:version] = @version
    get '/dashboard/show', params:params, as: :html
    assert_response :success
  end

  def heartbeat
    params = { id:@gid, version:@version }
    get '/dashboard/heartbeat', params:params, as: :json
  end

  def progress
    params = { id:@gid, version:@version }
    get '/dashboard/progress', params:params, as: :json
  end

end
