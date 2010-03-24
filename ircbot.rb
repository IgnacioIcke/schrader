#coding utf-8
#!/usr/bin/ruby

require "basebot"
require "date"
require "yaml"
require "net/http"
require 'rcregexps'
require 'dbconn'

class Ircbot < IRC
    def initialize(server, port, nick, channel, user)
        @server = server
        @port = port
        @nick = nick
        @channel = channel
        @db = Database.new()
        @db.reset() 
        @rcs = @db.getCollection();
    end
    def on_pub_msg(what, who, where)
        if who == 'rc':
            processRc(what)
        end
    end

    def processRc(what)
        if what =~ ReEdit
            page    = $1
            flags   = $2
            diff    = $3
            user    = $4
            bytes   = $5
            summary = $6
            doc = {'page' => $1, 'flags' => $1, 'diff' => $3, 
                   'user' => $4, 'bytes' => $5, 'summary' => $6,
                   'created_at' => Time.new.to_i
                    }

            @rcs.insert(doc)
        end
    end
end

def randomString( len )
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    newpass = ""
    1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
    return newpass
end

