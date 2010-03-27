# Based on http://rubystuff.org/ruby-irc/irc.rb.html

require "socket"

# This class represents a very simple IRC Bot
#

class IRC
    # Sends a message to the server
    # _what_ what to send
    def send(what)
        @irc.send "#{what}\n", 0
    end

    # Connects to the server
    def connect()
        #puts @server
        @irc = TCPSocket.open(@server, @port)
        send "USER schrader schrader schrader: schrader schrader"
        send "NICK #{@nick}"
        send "JOIN #{@channel}"
    end

    # Handle irc stuff that sends the server
    #
    # _what_ is the input

    def handle_server_input(what)
        case what.strip
            when /^PING :(.+)$/i
                #puts "[ Server ping ]"
                send "PONG :#{$1}"
            when /^:(.+?)!(.+?)@(.+?)\sPRIVMSG\s.+\s:[\001]PING (.+)[\001]$/i
                #puts "[ CTCP PING from #{$1}!#{$2}@#{$3} ]"
                send "NOTICE #{$1} :\001PING #{$4}\001"
            when /^:(.+?)!(.+?)@(.+?)\sPRIVMSG\s.+\s:[\001]VERSION[\001]$/i
                #puts "[ CTCP VERSION from #{$1}!#{$2}@#{$3} ]"
                send "NOTICE #{$1} :\001VERSION Rodillitas\001"
            when /^:(.+?)!(.+?)@(.+?)\sPRIVMSG\s(.+)\s:EVAL (.+)$/i
                #puts "[ EVAL #{$5} from #{$1}!#{$2}@#{$3} ]"
                send "PRIVMSG #{(($4==@nick)?$1:$4)} :#{evaluate($5)}"
            when /^:(.+?)!(.+?)@(.+?)\sPRIVMSG\s#(.+)\s:(.+)$/i
                on_pub_msg($5, $1, $4)
            when /^:(.+?)!(.+?)@(.+?)\sKICK\s#(.+)\s(\S+)\s:(.+)$/i 
                on_kick($1, $5, $4)
            else
                puts what
        end
    end

    # Someone said something in a public channel
    #
    # [_what_] what is said
    # [_who_] who said it
    # [_where_] where was it said

    def on_pub_msg(what, who, where)
        #puts "#{who} says #{what} at #{where}"
    end

    # Start the stuff. Handles exceptions and calls main_loop()
    def run
        connect()
        begin
            main_loop()
        rescue Interrupt
        rescue Exception => detail
            #puts detail.message()
            print detail.backtrace.join("\n")
            retry
        end
    end

    
    # Just keep on truckin' until we disconnect
    def main_loop()
        while true
            ready = select([@irc, $stdin], nil, nil, nil)
            next if !ready
            ready[0].each do |s|
                if s == $stdin then
                    return if $stdin.eof
                    s = $stdin.gets
                    send s
                elsif s == @irc then
                    return if @irc.eof
                    s = @irc.gets
                    handle_server_input(s)
                end
            end
        end
    end
end

