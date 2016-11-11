require 'cinch'

bot = Cinch::Bot.new do
  configure do |c|
    c.server = "irc.quakenet.org"
    c.channels = ["#ayanami-test"]
    c.nick = "ayanami"
  end

  on :message, /(https?:\/\/\S*)/ do |m, url|
    m.reply "Hello, #{m.user.nick}"
    debug "message contains url"
    debug url
  end
end

bot.start
