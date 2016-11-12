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
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      if uri.scheme == "https"
        http.use_ssl = true
      end
      req = Net::HTTP::Get.new(uri.request_uri)
      html = http.request(req)
      dom = Nokogiri(html.body)
      title = dom.css('title').first
      if title
        return title.content
      end
    end
  end

  on :message, /(https?:\/\/\S*)/ do |m, url|
    title = getTitle(url)
    if title
      m.reply title
    end
  end
end

bot.start
