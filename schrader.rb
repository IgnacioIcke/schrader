require 'ircbot'
require 'server'
require 'wiki'
require 'rubygems'
require 'rbmediawiki'

Configuration = YAML::load(File.open("config.yml"))
Userconf      = YAML::load(File.open("userconfig.yml"))

bot = Ircbot.new(Configuration['server'], Configuration['port'], Configuration['nick']+randomString(5), Configuration['channel'], Configuration['user'])

Thread.new() { bot.run()}

port = (ARGV[0] || 3000).to_i

api = Mediawiki.new(Userconf['user'], Userconf['password'], Configuration['api'])

webserver = Webserver.new(port, api, Configuration['site'], Userconf['admin'])
Thread.new() {webserver.run() }

while 1
end

