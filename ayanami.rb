require "cinch"
require "net/http"
require "nokogiri"
require "yaml"

bot = Cinch::Bot.new do
  configure do |c|
    begin
      config = YAML.load_file("config.yaml")
    rescue
      raise "problem loading config file!"
    end

    if !config["server"]
      raise "no server in the configuration file!"
    end

    if !config["channels"].kind_of?(Array)
      raise "no channels in the configuration file!"
    end

    c.server = config["server"]
    c.channels = config["channels"]
    c.nick = "ayanami"
  end

  helpers do
    def constructUrl(url)
      if url.start_with? "www."
        return "http://" + url
      else
        return url
      end
    end

    def checkContentIsHtml(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      if uri.scheme == "https"
        http.use_ssl = true
      end
      req = Net::HTTP::Head.new(uri.request_uri)
      response = http.request(req)

      if response.code != "200"
        puts "Discarding. Non-200 HTTP code"
        return false
      end

      if response["Content-Type"].include? "text/html"
        return true
      else
        puts "Discarding Content-Type #{response["Content-Type"]}. Probably binary content"
      end
      return false
    end

    def getHtml(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      if uri.scheme == "https"
        http.use_ssl = true
      end
      req = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(req)
      return response.body
    end

    def getTitle(url)
      uri = URI.parse(constructUrl(url))
      if(checkContentIsHtml(uri))
        html = getHtml(uri)
        dom = Nokogiri(html)
        title = dom.css("title").first
        if title
          return title.content
        end
      end
    end
  end

  on :message, /((https?:\/\/|www.)\S*)/ do |m, url|
    puts "Getting title for #{url}"
    title = getTitle(url)
    if title
      m.reply title
    end
  end
end

bot.start
