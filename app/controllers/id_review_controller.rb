
class IdReviewController < ApplicationController

  def drop_down
    @id = params['id'] = katas.completed(id.upcase)
    json = { exists: kata.exists? }
    if json[:exists]
      json[:id] = @id
    end
    render json:json
  end

end
