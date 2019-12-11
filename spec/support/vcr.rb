require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = Rails.root.join("spec/fixtures/vcr_cassettes")
  config.hook_into :webmock
  config.configure_rspec_metadata!
end

Module.new do
  def use_vcr
    before do
      unless VCR.current_cassette&.recording?
        allow(Transcription).to receive(:bucket) { "kikitool-test" }
      end
    end
  end

  def vcr_options name
    self.metadata[:recordable] = true
    path = Pathname.new(self.metadata[:file_path]).relative_path_from('spec')
    pre = path.to_s.gsub(/_spec.rb$/, '')
    {
      cassette_name: Pathname.new("#{pre}/#{name}"),
      match_requests_on: [:host],
      preserve_exact_body_bytes: true
    }
  end

  RSpec.configure do |config|
    config.filter_run :recordable if ENV.key?("TEST_RECORDING")
    config.extend self
  end
end
