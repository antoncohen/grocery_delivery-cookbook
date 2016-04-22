require 'foodcritic'
require 'kitchen'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

namespace :style do
  desc 'Run Ruby style checks'
  RuboCop::RakeTask.new(:ruby) do |t|
    t.options = ['-D']
  end

  desc 'Run Chef style checks'
  FoodCritic::Rake::LintTask.new(:chef) do |t|
    t.options = {
      fail_tags: ['any']
    }
  end
end

desc 'Run all style checks'
task style: ['style:ruby', 'style:chef']
task lint: [:style]

# Rspec and ChefSpec
desc 'Run ChefSpec examples'
RSpec::Core::RakeTask.new(:spec)

# Integration tests. Kitchen.ci
namespace :integration do
  desc 'Run Test Kitchen with Vagrant'
  task :vagrant do
    Kitchen.logger = Kitchen.default_file_logger
    Kitchen::Config.new.instances.each do |instance|
      instance.test(:always)
    end
  end
end

namespace :test do
  desc 'Run all style checks and unit tests'
  task quick: [:style, :spec]

  desc 'Run all style checks, unit tests, and integration tests'
  task all: [:style, :spec, 'integration:vagrant']
end

desc 'Run all style checks and unit tests'
task test: ['test:quick']

task default: [:test]
