class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @audios =
      current_user.audios_blobs.order(id: :desc)
        .each.with_object(Audio).map(&:becomes)
  end
end
