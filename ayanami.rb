require 'cinch'
require 'net/http'
require 'nokogiri'
require 'yaml'

bot = Cinch::Bot.new do
  configure do |c|
    begin
      config = YAML.load_file('config.yaml')
    rescue
      raise 'problem loading config file!'
    end

    raise 'no server in the configuration file!' unless config['server']

    unless config['channels'].is_a?(Array)
      raise 'no channels in the configuration file!'
    end

    c.server = config['server']
    c.channels = config['channels']
    c.nick = 'ayanami'
  end

  helpers do
    def construct_url(url)
      if url.start_with? 'www.'
        'http://' + url
      else
        url
      end
    end

    def check_content_is_html(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == 'https'
      req = Net::HTTP::Head.new(uri.request_uri)
      response = http.request(req)

      if response.code != '200'
        puts 'Discarding. Non-200 HTTP code'
        return false
      end

      if response['Content-Type'].include? 'text/html'
        return true
      else
        puts "Discarding Content-Type #{response['Content-Type']}. Probably binary content"
      end
      false
    end

    def get_html(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == 'https'
      req = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(req)
      response.body
    end

    def get_title(url)
      uri = URI.parse(construct_url(url))
      if check_content_is_html(uri)
        html = get_html(uri)
        dom = Nokogiri(html)
        title = dom.css('title').first
        return title.content.strip if title
      end
    end
  end

  on :message, %r{((https?://|www.)\S*)} do |m, url|
    puts "Getting title for #{url}"
    title = get_title(url)
    m.reply title if title
  end
end

bot.start
