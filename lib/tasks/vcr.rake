require "thor/shell"

extend Thor::Shell

namespace :vcr do
  task :record do
    env = {
      "RAILS_ENV" => "test",
      "TEST_RECORDING" => "1",
      "DISABLE_SPRING" => "1"
    }
    system env, "./bin/rspec",
      "--require", Rails.root.join("spec/rails_helper").to_s,
      "-P", "#{__dir__}/vcr/**/*_spec.rb"

    cassette_library_dir = Rails.root.join("spec/fixtures/vcr_cassettes")
    dir = Rails.root.join("spec/fixtures/vcr_cassettes/_/lib/tasks/vcr")
    Dir[dir.join("**/**.yml")].each do|f|
      obj = YAML.load_file(f)
      http_interactions = obj["http_interactions"]

      xs = http_interactions.inject([]) do |acc, i|
        if acc.empty?
          acc << i
        else
          last = Time.parse acc.last["recorded_at"]
          this = Time.parse i["recorded_at"]
          if 1.0 < this - last
            acc.pop
          end
          acc << i
        end
      end
      open(f, "w") do |io|
        io << YAML.dump(obj.merge("http_interactions" => xs))
      end
    end

    Dir[dir.join("**/*.yml")].each do |src|
      path = Pathname.new(src).relative_path_from(dir)
      dst = cassette_library_dir.join(path)
      FileUtils.mv src, dst, force: true
      say_status :update, dst.relative_path_from(Rails.root), :green
    end
  end
end
