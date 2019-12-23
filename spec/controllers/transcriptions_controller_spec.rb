require 'rails_helper'

RSpec.describe TranscriptionsController, type: :controller do
  authenticate_user

  describe "GET #show" do
    let(:transcription) { create :transcription, user: current_user }

    it "returns http success" do
      get :show, params: { id: transcription.id }
      expect(response).to have_http_status(:success)
    end
  end

end
