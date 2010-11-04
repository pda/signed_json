require 'bundler'
Bundler::GemHelper.install_tasks

desc "Run specs"
task :spec do
  system 'bundle exec rspec --color --format documentation spec/*_spec.rb'
end
