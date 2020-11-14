module Discordrb
  class Message
    def self.cached(id)
      CachedMessage[id]
    end

    delegate :server,   to: :channel
    delegate :username, to: :author
    delegate :name,     to: :channel, prefix: true
    delegate :name,     to: :server,  prefix: true

    def run_used_command
      command&.begin_call unless from_porygon?
    end

    def cache_in_db!
      CachedMessage.create(**to_cache)
    end

    def from_porygon?
      author.id == ::Bot.user_id
    end

    private

    def command
      Porygon::CommandDetector.detect(self)
    end

    def to_cache
      @to_cache ||= {
        id: id,
        author_id: author.id,
        channel_id: channel.id,
        server_id: server.id,
        creation_time: creation_time,
        content: content,
        attachment_data: attachments.map { |a| { url: a.url } }.to_json,
      }
    end

    class CachedMessage < Sequel::Model
      SIZE = Porygon.development? ? 10 : 8000
      
      unrestrict_primary_key

      def self.garbage_collect
        overflow = count - SIZE
        return unless overflow.positive?
        
        limit(overflow).destroy
      end

      def author
        server.member(author_id)
      end

      def server
        ::Bot.servers[server_id]
      end

      def attachments
        JSON.parse(attachment_data, object_class: OpenStruct)
      end

      def from_porygon?
        author_id == ::Bot.user_id
      end
    end
  end
end