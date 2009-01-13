
require 'open-uri'
require 'rss'

class SimpleRss < Plugin
  def initialize(bot)
    @bot = bot;

    @url = "http://www.raippa.fi/RecentChanges?action=rss_rc&unique=1"

    # Main thread of the rss reader, which polls given url
    @thread = Thread.new(@bot, @url) do |bot, url|

      open(url) {|f|
        feed = RSS::Parser.parse(f.read, false)
        feed.items.each{|item|
          puts "#{feed.title}: #{item.title}", item.link
          #bot.plugin_post item.title
        }
      }
      sleep(60)
    end
  end
end
