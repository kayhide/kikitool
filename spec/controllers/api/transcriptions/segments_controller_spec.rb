require 'rails_helper'

RSpec.describe Api::Transcriptions::SegmentsController, type: :controller do
  authenticate_user

  let(:transcription) { create :transcription }

  describe "GET #index" do
    it "returns http success" do
      get :index, xhr: true, params: { transcription_id: transcription.id }
      expect(response).to have_http_status(:success)
    end
  end

end
