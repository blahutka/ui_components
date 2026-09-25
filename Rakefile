require "bundler/setup"

# The dummy app's tasks (app:db:migrate…); `bin/rails test` prepares its test database with them
APP_RAKEFILE = File.expand_path("test/dummy/Rakefile", __dir__)
load "rails/tasks/engine.rake"

require "bundler/gem_tasks"

Dir.glob(File.expand_path("lib/tasks/*.rake", __dir__)).each { |task| load task }
