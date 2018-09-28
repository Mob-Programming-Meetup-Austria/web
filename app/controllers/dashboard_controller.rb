
class DashboardController < ApplicationController

  protect_from_forgery except: :heartbeat

  def show
    gather
    @title = 'dashboard:' + @group.short_id
  end

  def heartbeat
    gather
    respond_to { |format| format.js }
  end

  def progress
    render json: { animals: animals_progress }
  end

  private

  include DashboardWorker

end
