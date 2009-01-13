
require 'open-uri'
require 'rss'

class SimpleRss < Plugin
  def initialize(bot, config)
    @bot = bot;

    @threads = []

    # Main thread of the rss reader, which polls given url
    config['urls'].each{|u|
      @threads.push Thread.new(@bot, u) do |bot, url|

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
