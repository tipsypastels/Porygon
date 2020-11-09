module Porygon
  class BotClass
    attr_reader :markov, :member_join_list, :message_cache
    delegate :avatar_url, to: :profile

    def initialize
      @bot = Discordrb::Bot.new(token: ENV['BOT_TOKEN'])
      @markov = Porygon::MarkovStore.new
      @member_join_list = MemberJoinList.new(@bot)
      @message_cache = MessageCache.new(@bot)

      setup_translation_globals
      setup_handlers
    end

    def start
      @bot.ready { ready }
      @bot.run
    end

    def prefix
      @prefix ||= ENV.fetch('PREFIX', '!')
    end

    def user_id
      @bot.profile.id
    end
    
    def member_on(server)
      server.member(user_id)
    end

    def owner
      @owner ||= ENV.fetch('OWNER').to_i
    end

    def owner?(user)
      user.resolve_id == owner
    end

    private

    delegate :profile, to: :@bot

    def setup_translation_globals
      I18n.config.globals[:pre] = prefix
    end

    def setup_handlers
      @bot.message(&:handle_message)
      @bot.member_join(&:handle_join)
      @bot.member_leave(&:handle_leave)
      @bot.message_delete(&:handle_delete)
      @bot.user_ban(&:handle_ban)
      @bot.user_unban(&:handle_unban)
      @bot.channel_delete(&:handle_delete)
      @bot.server_role_delete(&:handle_delete)
    end

    def ready
      wait_for_member_list_to_be_accurate

      @member_join_list.build

      Database.start_logging
    end

    WAIT_TIME = 30.seconds

    def wait_for_member_list_to_be_accurate
      return if Porygon.development?

      Porygon::LOGGER.info \
        "Sleeping for #{WAIT_TIME} seconds until the member list is accurate."

      sleep WAIT_TIME
    end
  end
end