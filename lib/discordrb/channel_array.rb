module Discordrb
  class ChannelArray < ::Arguments::Array(Channel)
    ALL = 'all'.freeze

    def self.from_argument(error, arg, command)
      return command.server.channels if arg == ALL
      super
    end
  end
end