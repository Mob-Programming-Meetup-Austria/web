require_relative 'app_controller_test_base'

class IdReviewControllerTest < AppControllerTestBase

  def self.hex_prefix
    '5EFE47'
  end

  #- - - - - - - - - - - - - - - -

  test '408',
  'review exists==true' do
    in_kata(:stateless) {
      review(kata.id)
      assert exists?
    }
  end

  #- - - - - - - - - - - - - - - -

  test '409',
  'review exists==false' do
    review(hex_test_kata_id)
    refute exists?
  end

  #- - - - - - - - - - - - - - - -

  test '40A',
  'review with no id results in json with exists=false' do
    get '/id_review/drop_down', params:{}
    refute exists?
  end

  private

  def review(id)
    params = { 'format' => 'json', 'id' => id }
    get '/id_review/drop_down', params:params
    assert_response :success
  end

  def exists?
    json['exists']
  end

end
