require 'socket'
require 'dbconn'
require 'controller'
require 'cgi'

class Webserver
    def initialize(port, api, site, isAdmin)
        @port = port
        @server = TCPServer.new('localhost', port)
        @db = Database.new()
        @rcs = @db.getCollection()
        @api = api
        @site = site
        @isAdmin = true
    end
    def run
        while (session = @server.accept)
            gets = session.gets
            puts gets
            if gets =~ /GET (.*) HTTP/
                case $1
                when /^\/$/
                    session.print "HTTP/1.1 200/OK\r\nContent-type: text/html\r\n\r\n"
                    session.print showDiff
                    session.close
                when /^\/rollback\?user=(.*)&page=(.*)$/
                    session.print "HTTP/1.1 200/OK\r\nContent-type: text/html\r\n\r\n"
                    session.print @api.rollback(CGI::unescape($1), CGI::unescape($2))
                    session.close
                when /^\/main\.css$/
                    file = File.open('webstuff/main.css')
                    session.print file.read
                    session.close
                    file.close
                when /^\/icons-simple\.png$/
                    file = File.open('webstuff/icons/icons-simple.png', 'rb')
                    session.write file.read
                    session.close
                    file.close
                end
            else
                session.print "HTTP/1.1 404/Not Found\r\n\r\n"
                session.close
            end
        end
    end
    def showDiff 
        rc = @rcs.find_one()
        puts rc.inspect()
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

