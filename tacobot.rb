require 'rubygems'
require 'cinch'
require 'openssl'

require_relative 'plugins/search.rb'
require_relative 'plugins/admin.rb'
require_relative 'plugins/util.rb'
require_relative 'plugins/toolbox'



bot = Cinch::Bot.new do

  configure do |b|

    b.server = "irc.indieirc.net"
    b.channels = ["#tacobotdev"]
    #b.channels = ["#tacobotdev", "#jgallant"]

    b.nick = "taco"
    b.user = "taco"
    b.realname = "onerving's bot"

    b.plugins.prefix = /^\./

    b.plugins.plugins = [
      Tacobot::Admin::JoinPart,
      Tacobot::Admin::AutoRejoin,
      Tacobot::Admin::ChangeNick,
      Tacobot::Admin::ManageAdmins,
      Tacobot::Admin::Parrot,
      Tacobot::Search::Google,
      Tacobot::Search::UrbanDictionary,
      Tacobot::Search::Steam,
      Tacobot::Search::YouTube,
      Tacobot::Search::Wikipedia,
      Tacobot::Search::Wolfram,
      Tacobot::Util::Help,
      Tacobot::Util::URLParser,
      Tacobot::Util::IsUp,
      Tacobot::Util::DiceRoll,
      Tacobot::Util::Offender,
      Tacobot::Util::EightBall
      #Tacobot::Util::RandomListener
      #SteamSales,
    ]

  end

end

bot.start