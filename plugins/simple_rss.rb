
require 'open-uri'
require 'rss'

# TODO: Subscription handling
# !subscribe feed-url command
#
# adds new subscription so that SimpleRSS notifies
# target channel or user when new items are added to
# the feed.
# If command is given on the channel then target is
# that channel, otherwise target is the user
#
# !unsubscribe

class SimpleRss < Plugin
  def initialize(bot, config)
    @bot = bot;

    @threads = []

    # Main thread of the rss reader, which polls given url
    config['urls'].each{|u|
      @threads << Thread.new(@bot, u) do |bot, url|

        open(url) {|f|
          feed = RSS::Parser.parse(f.read, false)
          feed.items.each{|item|
            puts "#{feed.title}: #{item.title}", item.link
            #bot.plugin_post item.title
          }
        }
        sleep(60)
      end
    }
  end

  def handlers()
    {"!subscribe" => :on_subscribe,
      "!unsubscribe" => :on_unsubscribe}
  end

  def on_help()
    # Prints usage info. NotifBot calls this
    # when !help is called.
  end

  def on_subscribe
  end

  def on_unsubscribe
  end

end
