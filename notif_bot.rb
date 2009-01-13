#! /usr/bin/env ruby

require 'rubygems'
require 'net/irc' # net-irc gem
require 'yaml'

require 'plugin'

# Parse a few random irc log files from the directories given
# as command line parameters.
class NotifBot < Net::IRC::Client
  def initialize(config_file)
    @config = YAML::load(File.open(config_file))

    super(@config['server'],@config['port'], {
            :nick => @config['nick'],
            :user => @config['nick'],
            :real => @config['realname']
          })
  end

  def on_message(m)
    super
    # This may be network dependant but at least in IRCnet End of MOTD
    # is command 376.
    #if (/End of MOTD/.match(m) and (@joined_channels == []))
    if (m.command == '376')
      post JOIN, @config['channel']
    else
    end
  end
end

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
