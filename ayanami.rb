require 'cinch'
require 'net/http'
require 'nokogiri'

bot = Cinch::Bot.new do
  configure do |c|
    c.server = "irc.quakenet.org"
    c.channels = ["#ayanami-test"]
    c.nick = "ayanami"
  end

  helpers do
    def getTitle(url)
      uri = URI(url)
      html = Net::HTTP.get(uri)
      dom = Nokogiri(html)
      title = dom.css('title').first
      if title
        return title.content
      end
    end
  end

  on :message, /(https?:\/\/\S*)/ do |m, url|
    # m.reply "Hello, #{m.user.nick}"
    # debug "message contains url"
    title = getTitle(url)
    if title
      m.reply title
    end
    # debug url
  end
end

bot.start
