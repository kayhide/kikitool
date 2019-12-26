namespace :assets do
  task :append_yarn_bin do
    ENV["PATH"] = `yarn bin`.chomp + ":" + ENV["PATH"]
  end

  task precompile: :append_yarn_bin
end

