class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @transcriptions =
      current_user.transcriptions.order(id: :desc)
  end
end
