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

  def vcr_options name, **opts
    path = Pathname.new(self.metadata[:file_path]).relative_path_from('spec')
    pre = path.to_s.gsub(/_spec.rb$/, '')
    {
      cassette_name: Pathname.new("#{pre}/#{name}"),
      match_requests_on: [:host],
      preserve_exact_body_bytes: true,
      **opts
    }
  end

  RSpec.configure do |config|
    if ENV.key?("TEST_RECORDING")
      config.filter_run vcr: -> () { true }
      config.filter_run_excluding :play_only
    end
    config.extend self
  end
end
