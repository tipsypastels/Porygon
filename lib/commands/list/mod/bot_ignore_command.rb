module Commands
  class BotIgnoreCommand < Command
    self.tag    = 'botignore'
    self.access = Permission.ban_members

    args do |a|
      a.arg :member, Discordrb::Member
    end

    def call(member:)
      return no_author if member == author
      return already_ignored(member) if member.server_ignored?

      member.server_ignore(by: author)

      embed do |e|
        e.color       = Porygon::COLORS.ok
        e.title       = t('done.title')
        e.description = t('done.description', member: member.mention)
      end
    end

    private

    def no_author
      embed do |e|
        e.color       = Porygon::COLORS.warning
        e.title       = t('no_author.title')
        e.description = t('no_author.description')
      end
    end

    def already_ignored(member)
      embed do |e|
        e.color       = Porygon::COLORS.warning
        e.title       = t('already.title', member: member.display_name)
        e.description = t('already.description')
      end
    end
  end
end