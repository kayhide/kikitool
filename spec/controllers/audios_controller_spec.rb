require 'rails_helper'

RSpec.describe AudiosController, type: :controller do
  authenticate_user

  describe "POST #create" do
    let(:file) { 'files/visby.mp3' }
    let(:valid_params) {
      {
        file: fixture_file_upload(file),
        speakers_count: 2
      }
    }

    context "with valid params" do
      it "creates a new Audio" do
        expect {
          post :create, params: { audio: valid_params }
        }.to change(Audio, :count).by(1)
      end

      it "creates a new Transcription" do
        expect {
          post :create, params: { audio: valid_params }
        }.to change(Transcription, :count).by(1)
        expect(Transcription.last.audio_blob).to eq current_user.audios_blobs.last
      end

      it "enqueues TranscribeJob" do
        expect {
          post :create, params: { audio: valid_params }
        }.to have_enqueued_job(TranscribeJob)
               .with(Transcription.last)
      end

      it "redirects to the root page" do
        post :create, params: { audio: valid_params }
        expect(response).to redirect_to([:root])
      end
    end
  end

  describe "DELETE #destroy" do
    let(:file_path) { fixture_path.join('files/visby.mp3') }
    let!(:audio) {
      current_user.audios.attach(io: file_path.open, filename: file_path.basename)
      current_user.audios_blobs.last.becomes(Audio)
    }

    it "euqueues PurgeJob" do
      assert_enqueued_with job: ActiveStorage::PurgeJob do
        delete :destroy, params: { id: audio.id }
      end
    end

    it "destroys the requested audio after PurgeJob performed" do
      expect {
        perform_enqueued_jobs do
          delete :destroy, params: { id: audio.id }
        end
      }.to change(Audio, :count).by(-1)
    end

    it "destroys transcription if any" do
      create_list :transcription, 2, audio: audio
      expect {
        delete :destroy, params: { id: audio.id }
      }.to change(Transcription, :count).by(-2)
    end

    it "redirects to the root page" do
      delete :destroy, params: { id: audio.id }
      expect(response).to redirect_to([:root])
    end
  end

end
