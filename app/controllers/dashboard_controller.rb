class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @audios = current_user.audios_blobs
  end
end
