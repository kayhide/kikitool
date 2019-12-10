require 'rails_helper'

vcr_create = {
  cassette_name: "audios_controller/create",
  match_requests_on: [:host],
  preserve_exact_body_bytes: true
}

vcr_destroy = {
  cassette_name: "audios_controller/destroy",
  match_requests_on: [:host],
  preserve_exact_body_bytes: true
}

RSpec.describe AudiosController, type: :controller do
  authenticate_user

  describe "POST #create" do
    let(:file) { 'files/visby.mp3' }
    let(:valid_params) {
      {
        file: fixture_file_upload(file)
      }
    }

    context "with valid params" do
      it "creates a new Audio", vcr: vcr_create do
        expect {
          post :create, params: { audio: valid_params }
        }.to change(Audio, :count).by(1)
      end

      it "redirects to the root page", vcr: vcr_create do
        post :create, params: { audio: valid_params }
        expect(response).to redirect_to([:root])
      end
    end
  end

  describe "DELETE #destroy" do
    let(:file_path) { fixture_path.join('files/visby.mp3') }

    before do
      current_user.audios.attach(io: file_path.open, filename: file_path.basename)
    end

    it "euqueues PurgeJob", vcr: vcr_destroy do
      audio = Audio.last
      assert_enqueued_with job: ActiveStorage::PurgeJob do
        delete :destroy, params: { id: audio.id }
      end
    end

    it "destroys the requested audio after PurgeJob performed", vcr: vcr_destroy do
      audio = Audio.last
      expect {
        perform_enqueued_jobs do
          delete :destroy, params: { id: audio.id }
        end
      }.to change(Audio, :count).by(-1)
    end

    it "redirects to the root page", vcr: vcr_destroy do
      audio = Audio.last
      delete :destroy, params: { id: audio.id }
      expect(response).to redirect_to([:root])
    end
  end

end
