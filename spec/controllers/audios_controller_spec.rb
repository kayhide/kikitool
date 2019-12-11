require 'rails_helper'

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
      it "creates a new Audio" do
        expect {
          post :create, params: { audio: valid_params }
        }.to change(Audio, :count).by(1)
      end

      it "redirects to the root page" do
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

    it "euqueues PurgeJob" do
      audio = Audio.last
      assert_enqueued_with job: ActiveStorage::PurgeJob do
        delete :destroy, params: { id: audio.id }
      end
    end

    it "destroys the requested audio after PurgeJob performed" do
      audio = Audio.last
      expect {
        perform_enqueued_jobs do
          delete :destroy, params: { id: audio.id }
        end
      }.to change(Audio, :count).by(-1)
    end

    it "redirects to the root page" do
      audio = Audio.last
      delete :destroy, params: { id: audio.id }
      expect(response).to redirect_to([:root])
    end
  end

end
