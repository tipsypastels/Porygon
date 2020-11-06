module Discordrb
  class Channel
    MENTION_FORMAT = /^<#([\d]+)>$/
    CURRENT_CHANNEL_SHORTHANDS = %w[here .]

    def self.from_argument(error, name, command)
      return command.channel if name.in?(CURRENT_CHANNEL_SHORTHANDS)
      command.server.find_text_channel(name) || error[:nonexistant, arg: name]
    end
    
    def send_message(content, tts = false, embed = nil, attachments = nil)
      @bot.send_message(@id, content, tts, embed, attachments)
    end

    def send_temporary_message(
      content, 
      timeout, 
      tts = false, 
      embed = nil, 
      attachments = nil
    )
      @bot.send_temporary_message(@id, content, timeout, tts, embed, attachments)
    end

    def send_embed(message = '', embed = nil, attachments = nil)
      embed ||= Discordrb::Webhooks::Embed.new
      yield(embed) if block_given?
      send_message(message, false, embed, attachments)
    end
  end
end