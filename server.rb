require 'socket'
require 'dbconn'
require 'controller'
require 'cgi'
require 'erb'

# Class that represents a simple web server
class Webserver
    # [_port_] Port we are listening to
    # [_api_] rbmediawiki API class
    # [_site_] Url of the wiki
    # [_isAdmin_] Whether the user is admin of the wiki or not 
    def initialize(port, api, site, isAdmin)
        @port = port
        @server = TCPServer.new('localhost', port)
        @db = Database.new()
        @api = api
        @site = site
        @isAdmin = true
    end

    # Main handler. Handles the different requests.
    def main_loop(session)
         gets = session.gets
         if gets =~ /GET (.*) HTTP/
             case $1
             when /^\/$/
                 session.print "HTTP/1.1 200/OK\r\nContent-type: text/html\r\n\r\n"
                 session.print showDiff
             when /^\/rollback\?user=(.*)&page=(.*)$/
                 session.print "HTTP/1.1 200/OK\r\nContent-type: text/html\r\n\r\n"
                 user = CGI::unescape($1)
                 page = CGI::unescape($2)
                 rolled = @api.rollback(user, page)
                 if rolled 
                     @db.insertLog(t.rollbacked + user + " "+ t.on+" "+page)
                 else
                     @db.insertLog(t.revertedFirst + page)
                 end
             when /^\/log$/
                 controller = ShowLogSnippetController.new(@db.countRcs, @db.retrieveLog(5))
                 session.print controller.generateRawHtml

             when /^\/cleanRc$/
                 @db.cleanRc()

             when /^\/whitelist\?user=(.*)$/
                 user = CGI::unescape($1)
                 @db.addWL(user)
                 @db.insertLog(user + t.whitelisted)

             when /^\/main\.css$/
                 session.print "HTTP/1.1 200/OK\r\nContent-type: text/css\r\n\r\n"
                 file = File.open('webstuff/main.css')
                 session.print file.read
                 file.close
             when /^\/icons-simple\.png$/
                 file = File.open('webstuff/icons/icons-simple.png', 'rb')
                 session.write file.read
                 file.close
             when /^\/favicon\.ico$/
                 file = File.open('webstuff/favicon.ico', 'rb')
                 session.write file.read
                 file.close
             when /^\/removerc\.png$/
                 file = File.open('webstuff/removerc.png', 'rb')
                 session.write file.read
                 file.close
             else
                 puts "unable to handle #{gets}"
                 session.print "HTTP/1.1 404/Not Found\r\nContent-type: text/html\r\n\r\n"
             end
         else
             session.print "HTTP/1.1 404/Not Found\r\n\r\n"
         end
         session.close
    end

    # Start the stuff. Handles exceptions and calls main_loop()
    def run
        while (session = @server.accept)
            Thread.new() {
                begin
                    main_loop(session)
                rescue Interrupt
                rescue Exception => detail
                    puts detail.message()
                    print detail.backtrace.join("\n")
                end
            }
        end
    end

    # Calls the controller ShowDiffController and sends the html to the client
    def showDiff 
        rc = @db.retrieveRc
        if !rc
            return ShowLogController.new(@db.countRcs, @db.retrieveLog(5)).generateHtml
        end
        @db.reviewedRc(rc[:id])
        controller = ShowDiffController.new(@site, @isAdmin, rc[:diff], rc[:htmldiff], rc[:page], rc[:user], @db.countRcs, @db.retrieveLog(5))
        return controller.generateHtml
    end
end

