require_relative 'http_service_exception'

class CustomException < HttpServiceException

  def initialize(message)
    super
  end

end
