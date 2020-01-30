class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @form = Audio.new(speakers_count: 2)
  end
end
