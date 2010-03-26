#coding utf-8
#!/usr/bin/ruby

require "basebot"
require "date"
require "yaml"
require "net/http"
require 'dbconn'

ReEdit = Regexp.new(/\x0314\[\[\x0307([^\]]*)\x0314\]\]\x034 (\w*)\x0310 \x0302(http:\/\/\S*)\x03 \x035\*\x03 \x0303([^\x03]+)\x03 \x035\*\x03 \(([^\)]*)\) \x0310(.*)\x03$/)

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
        @db.resetRc() 
        @api = api
    end

    # Filters messages sent by _rc_ the recent changes bot and sents them to
    # processRc
    #
    # [_what_] what was said
    # [_who_] who said it
    # [_where_] where was it said
    def on_pub_msg(what, who, where)
        if who == 'rc':
            processRc(what)
        end
    end

    # Processes a Recent Change message (_what_) and stores it in the db.
    def processRc(what)
        if what =~ ReEdit
            page    = $1
            flags   = $2
            diff    = $3
            user    = $4
            bytes   = $5
            summary = $6

            if diff =~ /diff=(\d+)&oldid=(\d+)/
                previd  = $1
                curid = $2
            end

            htmldiff = @api.getDiff(page, previd, curid)

            @db.insertRc($1, $2, $3, $4, $5, $6, htmldiff)
        end
    end
end

def randomString( len )
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    newpass = ""
    1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
    return newpass
end

