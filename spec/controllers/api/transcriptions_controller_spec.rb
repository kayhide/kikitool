require 'rails_helper'

RSpec.describe Api::TranscriptionsController, type: :controller do
  authenticate_user

  describe "GET #index" do
    it "returns http success" do
      create_list :transcription, 2, user: current_user
      get :index, xhr: true
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #show" do
    let(:transcription) { create :transcription }

    it "returns http success" do
      get :show, xhr: true, params: { id: transcription.id }
      expect(response).to have_http_status(:success)
    end

    it "returns a json object of Transcription" do
      get :show, xhr: true, params: { id: transcription.id }
      obj = JSON.parse(response.body)
      expect(obj["id"]).to eq transcription.id
    end
  end

end
