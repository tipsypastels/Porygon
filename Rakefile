LOAD_PORY = -> do
  ENV['SKIP_BOT'] = 'true'
  require_relative './main'
end

namespace :db do
  task :migrate, [:version] do |_t, args|
    require 'dotenv/load'
    require 'sequel/core'

    Sequel.extension(:migration)

    version = args[:version]&.to_i
    sequel  = Sequel.connect adapter: :postgres,
                             user: ENV['DB_USERNAME'],
                             password: ENV['DB_PASSWORD'],
                             database: ENV['DB']

    Sequel::Migrator.run(sequel, 'migrations', target: version)
  end
end

namespace :cleanup do
  task :message_cache do
    LOAD_PORY[]

    Discordrb::Message::CachedMessage.garbage_collect
  end
end

namespace :cycle do
  task :activity do
    LOAD_PORY[]

    Porygon::MessageBus::Input.cycle_activity
  end
end