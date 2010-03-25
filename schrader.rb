# Schrader is an antivandal tool for wikimedia based projects
# 
# http://github.com/IgnacioIcke/schrader
#
# It connects an irc bot to irc://browne.wikimedia.org where receives 
# a list of recent changes.
# 
# It stores them in a db, and a web server (listening by default on port 3000).
#
# Author::    Ignacio Icke  (mailto:chabawiki@gmail.com)
# Copyright:: Copyright (c) 2010 Ignacio Icke
# License::   Distributed under GPLv3

# This main script sets the bot and the web server up and connects to the
# mediawiki project

require 'ircbot'
require 'server'
require 'wiki'
require 'rubygems'
require 'rbmediawiki'

# Load general configuration
Configuration = YAML::load(File.open("config.yml"))
# Load private user configuration (user, *password*)
Userconf      = YAML::load(File.open("userconfig.yml"))

# Run the irc bot
bot = Ircbot.new(Configuration['server'], Configuration['port'], Configuration['nick']+randomString(5), Configuration['channel'], Configuration['user'])
Thread.new() { bot.run()}

# Register into Mediawiki
api = Mediawiki.new(Userconf['user'], Userconf['password'], Configuration['api'])

# Set the webserver up
port = (ARGV[0] || 3000).to_i
webserver = Webserver.new(port, api, Configuration['site'], Userconf['admin'])
Thread.new() {webserver.run() }

# Dirty infinite loop
while 1
end

