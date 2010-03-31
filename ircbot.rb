#coding utf-8
#!/usr/bin/ruby

require "basebot"
require "date"
require "yaml"
require "net/http"
require 'dbconn'

ReEdit = Regexp.new(/\[\[(.*)\]\] +(.*) +([^\s]+) +\* +(.*?) +\* +\(.*?\) +(.*)$/)

# This class is son of IRC, implements specific handlers for schrader

class Ircbot < IRC

    # [_server_] IRC server where connect the bot to
    # [_port_] Port of the server
    # [_nick_] Nick of our bot
    # [_channel_] Channel to connect the bot to
    # [_api_] Mediawiki api
    def initialize(server, port, nick, channel, user, api)
        @server = server
        @port = port
        @nick = nick
        @channel = channel
        @db = Database.new()
        @api = api
    end

    # Filters messages sent by _rc_ the recent changes bot and sents them to
    # processRc
    #
    # [_what_] what was said
    # [_who_] who said it
    # [_where_] where was it said
    def on_pub_msg(what, who, where)
        if who == 'rc'
            processRc(what)
        end
    end

    # Processes a Recent Change message (_what_) and stores it in the db.
    def processRc(what)
        #colors and bold => shitty IRC stuff
        what.gsub!(/\x03\d{0,2}/,'')
        what.gsub!(/\x02\d{0,2}/,'')
        if what =~ ReEdit
            page    = $1
            flags   = $2
            diff    = $3
            user    = $4
            summary = $5
            #new page
            if flags =~ /N/ and diff =~ /oldid=(\d+)/
                curid = $1
                #Open in new thread to speed up things
                Thread.new() {
                    htmldiff = @api.getRevision(page, curid)
                    @db.insertRc(page, flags, diff, curid, user, summary, htmldiff)
                }
            #edit
            elsif diff =~ /diff=(\d+)&oldid=(\d+)/ 
                curid  = $1
                previd = $2

                #Open in new thread to speed up things
                Thread.new() {
                    htmldiff = @api.getDiff(page, curid, previd)

                    @db.insertRc(page, flags, diff, curid, user, summary, htmldiff)
                }
            end
        end
    end
end

def randomString( len )
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    newpass = ""
    1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
    return newpass
end

