#! /usr/bin/env ruby

require 'rubygems'
require 'net/irc' # net-irc gem
require 'yaml'

require 'plugin'

module NotifBotConstants
  # This may be network dependant but at least in IRCnet End of MOTD
  # is command 376.
  EOMOTD = 376
end

# Parse a few random irc log files from the directories given
# as command line parameters.
class NotifBot < Net::IRC::Client
  include NotifBotConstants

  def initialize(config_file)
    @config = YAML::load(File.open(config_file))

    super(@config['server'],@config['port'], {
            :nick => @config['nick'],
            :user => @config['nick'],
            :real => @config['realname']
          })
  end

  def initialize_plugins
    # open plugins dir
    # loop files inside, and require them
    # @config contains configuration for each plugin named with plugin classname
    # initialize each plugin with config data
  end

  def on_message(m)
    super
    if (m.command == EOMOTD)
      post JOIN, @config['channel']
    else
    end
  end

  def on_help()
    # answers to !help
  end
end

if __FILE__ == $0
  config_file = ['./config.yml',
                 './notifbotrc',
                 '~/.notifbotrc'].select{|f|
    f && File.file?(f)
  }.first

  if config_file
    NotifBot.new(config_file).start
  else
    puts "No config file found."
  end
end
