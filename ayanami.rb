require 'cinch'
require 'net/http'
require 'nokogiri'
require 'yaml'

bot = Cinch::Bot.new do
  configure do |c|
    begin
      config = YAML.load_file('config.yaml')
    rescue
      raise "problem loading config file!"
    end

    if !config['server']
      raise "no server in the configuration file!"
    end

    if !config['channels'].kind_of?(Array)
      raise "no channels in the configuration file!"
    end

    c.server = config['server']
    c.channels = config['channels']
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
