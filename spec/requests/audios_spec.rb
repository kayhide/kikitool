require 'rails_helper'

RSpec.describe "Audios", type: :request do
  authenticate_user

  let(:file) { 'files/visby.mp3' }
  let(:valid_params) {
    {
      file: fixture_file_upload(file)
    }
  }

  it "works!" do
    expect {
      post url_for([:audios]), params: { audio: valid_params }
    }.to change(Audio, :count).by(1)
    expect(response).to redirect_to(:root)

    audio = Audio.last
    expect {
      perform_enqueued_jobs do
        delete url_for(audio)
      end
    }.to change(Audio, :count).by(-1)
    expect(response).to redirect_to(:root)
  end
end
