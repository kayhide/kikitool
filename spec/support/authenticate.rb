Module.new do
  def authenticate_user
    let(:current_user) { @current_user }

    before do
      @current_user = block_given? ? yield : FactoryBot.create(:user)
      sign_in(current_user)
    end
  end

  RSpec.configure do |config|
    config.include Devise::Test::ControllerHelpers, type: :controller
    config.extend self, type: :controller
  end
end

Module.new do
  def authenticate_user
    let(:current_user) { @current_user }

    before do
      @current_user = block_given? ? yield : FactoryBot.create(:user)
      post url_for([:user, :session]), params: { user: { email: current_user.email, password: current_user.password } }
    end
  end

  RSpec.configure do |config|
    config.extend self, type: :request
  end
end
