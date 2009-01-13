
require 'net/http'
require 'net/https'
require 'rss'

class SimpleRss < Plugin
  def initialize(bot)
    @bot = bot;

    @url = URI.parse("http://www.raippa.fi/RecentChanges?action=rss_rc&unique=1&ddiffs=1")
    @http = Net::HTTP.new(@url.host, @url.port)
    # TODO: Check if https, and then use SSL
    # @http.use_ssl = true
    # @http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    # Main thread of the rss reader, which polls given url
    @thread = Thread.new(@bot, @http, @url) do |bot, http, url|
      req = Net::HTTP::Get.new(url.path)
      feed = RSS::Parser.parse(http.request(req).body, false)

      feed.items.each{|item|
        bot.plugin_post item.title
      }
    end
  end
end
