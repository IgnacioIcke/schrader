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
        @lastdiff = 0
    end

    # Main handler. Handles the different requests.
    def main_loop(session)
         gets = session.gets
         if gets =~ /GET (.*) HTTP/
             case $1
             when /^\/$/
                 session.print "HTTP/1.1 200/OK\r\nContent-type: text/html\r\n\r\n"
                 rc = @db.retrieveRc(@lastdiff)
                 session.print showDiff(rc)
             when /^\/lastDiff$/
                 session.print "HTTP/1.1 200/OK\r\nContent-type: text/html\r\n\r\n"
                 rc = @db.retrieveLastRc(@lastdiff)
                 session.print showDiff(rc)
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
                 session.print "HTTP/1.1 200/OK\r\nContent-type: text/html\r\n\r\n"
                 controller = ShowLogSnippetController.new(@db.countRcs(@lastdiff), @db.retrieveLog(5))
                 session.print controller.generateRawHtml

             when /^\/editWL$/
                 session.print "HTTP/1.1 200/OK\r\nContent-type: text/html\r\n\r\n"
                 session.print editWL

             when /^\/clearWL$/
                 session.print "HTTP/1.1 200/OK\r\nContent-type: text/html\r\n\r\n"
                 @db.clearWL()
                 session.print editWL

             when /^\/clearRc$/
                 @db.clearRc()

             when /^\/addToWL\?user=(.*)$/
                 user = CGI::unescape($1)
                 @db.addWL(user)
                 session.print "HTTP/1.1 200/OK\r\nContent-type: text/html\r\n\r\n"
                 session.print editWL
             when /^\/addToWLFromWiki\?page=(.*)$/
                 page = CGI::unescape($1)

                 addToWLFromWiki(page)
                 session.print "HTTP/1.1 200/OK\r\nContent-type: text/html\r\n\r\n"
                 session.print editWL

             when /^\/removeFromWL\?user=(.*)$/
                 id = CGI::unescape($1)
                 @db.removeFromWL(id)
                 session.print "HTTP/1.1 200/OK\r\nContent-type: text/html\r\n\r\n"
                 session.print editWL

             when /^\/whitelist\?user=(.*)$/
                 user = CGI::unescape($1)
                 @db.addWL(user)
                 @db.insertLog(user + t.whitelisted)

             when /^\/patrol\?id=(.*)&page=(.*)$/
                 rcid = $1
                 page = $2
                 @api.patrol(rcid, page)
                 @db.insertLog(page + t.patrolled)

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
             when /^\/remove\.png$/
                 file = File.open('webstuff/remove.png', 'rb')
                 session.write file.read
                 file.close
             when /^\/remove-off\.png$/
                 file = File.open('webstuff/remove-off.png', 'rb')
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

    def addToWLFromWiki(page)
        wikipage = @api.getPage(page)
        if wikipage
            inPres = Regexp.new('<pre>(.*)</pre>', Regexp::MULTILINE)
            if wikipage =~ inPres
                userList = $1 
                userList.each_line do |user| 
                    @db.addWL(user)
                end
            end
        end
    end
    # Calls the controller ShowDiffController and sends the html to the client
    def showDiff(rc)
        if !rc
            return ShowLogController.new(@db.countRcs(@lastdiff), @db.retrieveLog(5)).generateHtml
        end
        if rc[:flags] =~ /N/
            newpage = true
        else
            newpage = false
        end
        @lastdiff = rc[:id]
        controller = ShowDiffController.new(@site, @isAdmin, rc[:diff], rc[:htmldiff], rc[:rcid], rc[:page], rc[:user], rc[:summary], @db.countRcs(@lastdiff), @db.retrieveLog(5), newpage)
        return controller.generateHtml
    end

    # Calls the controller EditWLController to edit the White list
    def editWL
        wl = @db.getWL
        return EditWLController.new(wl).generateHtml
    end
end

