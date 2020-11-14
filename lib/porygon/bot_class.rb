module Porygon
  class BotClass
    ACTIVITIES = I18n.t('bot_activities')

    attr_reader :markov, :member_join_list, :stats
    delegate :servers, :profile, to: :@bot
    delegate :avatar_url, to: :profile

    def initialize
      @bot = Discordrb::Bot.new(token: ENV['BOT_TOKEN'], parse_self: true)
      @stats = OpStatsTracker.new
      @markov = Porygon::MarkovStore.new
      @message_bus = MessageBus::Output.new
      @member_join_list = MemberJoinList.new(@bot)

      setup_translation_globals
      setup_handlers
    end

    def start
      unless ENV['SKIP_BOT']
        @bot.ready { ready }
        @bot.run
      end
    end

    def prefix
      @prefix ||= ENV.fetch('PREFIX', '!')
    end

    def user_id
      profile.id
    end
    
    def member_on(server)
      server.member(user_id)
    end

    def owner
      @owner ||= @bot.user(owner_id)
    end

    def owner_id
      @owner_id ||= ENV.fetch('OWNER').to_i
    end

    def owner?(user)
      user.resolve_id == owner
    end

    def owner_avatar
      owner.avatar_url || ENV['FALLBACK_OWNER_AVATAR']
    end

    def activity=(activity)
      @bot.playing = activity
    end

    def cycle_activity
      self.activity = ACTIVITIES.sample
    end

    private

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
      if @ready_run
        Porygon::LOGGER.info('Reconnected!')
      else
        @ready_run = true

        Porygon::LOGGER.info("We're ready to go!")

        cycle_activity
        @stats.start_timing
        @member_join_list.build
        @message_bus.start_listening

        Database.start_logging
      end
    end
  end
end