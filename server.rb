require 'socket'
require 'dbconn'
require 'controller'
require 'cgi'

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
        @rcs = @db.getCollection()
        @api = api
        @site = site
        @isAdmin = true
    end

    # Main handler. Handles the different requests.
    def run
        while (session = @server.accept)
            gets = session.gets
            puts gets
            if gets =~ /GET (.*) HTTP/
                case $1
                when /^\/$/
                    session.print "HTTP/1.1 200/OK\r\nContent-type: text/html\r\n\r\n"
                    session.print showDiff
                when /^\/rollback\?user=(.*)&page=(.*)$/
                    session.print "HTTP/1.1 200/OK\r\nContent-type: text/html\r\n\r\n"
                    session.print @api.rollback(CGI::unescape($1), CGI::unescape($2))
                when /^\/main\.css$/
                    file = File.open('webstuff/main.css')
                    session.print file.read
                    file.close
                when /^\/icons-simple\.png$/
                    file = File.open('webstuff/icons/icons-simple.png', 'rb')
                    session.write file.read
                    file.close
                else
                    puts "unable to handle #{gets}"
                    session.print "HTTP/1.1 404/Not Found\r\nContent-type: text/html\r\n\r\n"
                end
                session.close
            else
                session.print "HTTP/1.1 404/Not Found\r\n\r\n"
                session.close
            end
        end
    end

    # Calls the controller ShowDiffController and sends the html to the client
    def showDiff 
        rc = @rcs.find_one()
        if !rc
            return ''
        end
        if rc['diff'] =~ /diff=(\d+)&oldid=(\d+)/
            previd  = $1
            curid = $2
        end
        htmldiff = @api.getDiff(rc['page'],previd, curid)

        controller = ShowDiffController.new(@site, @isAdmin, rc['diff'], htmldiff, rc['page'], rc['user'])
        @rcs.remove({'diff' => rc['diff']})
        return controller.generateHtml
    end
end

