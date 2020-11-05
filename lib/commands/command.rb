module Commands
  class Command
    include Porygon::MessageFormatter
    include Packaged, Respondable, Taggable, Rescuable
    include Translatable, Documentable, Listable, FromArgument

    class << self
      attr_accessor :args, :access, :allow_dm

      def from_argument(arg, *)
        TAGS[arg.downcase] || arg_err('nonexistant', arg: arg)
      end
    end

    attr_reader :message, :args, :used_tag, :raw_args
    delegate :channel, to: :message
    delegate :server, to: :channel
    delegate :access, :allow_dm, :usage, to: :class
  
    def initialize(message, used_tag, raw_args)
      @message  = message
      @used_tag = used_tag
      @raw_args = raw_args
    end
    
    def begin_call
      return unless should_call?
      
      with_error_handling do
        parse_args
        call
        CommandLogger.used_command(self)
      end
    end

    private

    def parse_args
      @args = self.class.args&.parse(raw_args, self)
    end

    def should_call?
      return false if @aborted
      return false if invalid_access?
      return false if used_in_invalid_context?

      true
    end

    def invalid_access?
      return unless access

      if (error_message = access.call(message))
        CommandLogger.permission_error(self, error_message)
        true
      end
    end

    def used_in_invalid_context?
      !message.channel.server && !allow_dm
    end
  end
end