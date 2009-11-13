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

class String
  # By default, +camelize+ converts strings to UpperCamelCase. If the argument to camelize
  # is set to <tt>:lower</tt> then camelize produces lowerCamelCase.
  #
  # +camelize+ will also convert '/' to '::' which is useful for converting paths to namespaces.
  #
  # "active_record".camelize # => "ActiveRecord"
  # "active_record".camelize(:lower) # => "activeRecord"
  # "active_record/errors".camelize # => "ActiveRecord::Errors"
  # "active_record/errors".camelize(:lower) # => "activeRecord::Errors"
  def camelize(first_letter = :upper)
    case first_letter
    when :upper then self.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
    when :lower then self.first.downcase + self.camelize[1..-1]
    end
  end
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
    @plugins = []
    @config['active_plugins'].each{|p|
      class_name = File.basename(p, ".rb").camelize
      require p
      @plugins << eval(class_name).new(self, @config[class_name])
    }
  end

  def on_message(m)
    super
    if (m.command == EOMOTD)
      self.initialize_plugins
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
