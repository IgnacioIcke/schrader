require 'socket'
require 'dbconn'
require 'controller'

class Webserver
    def initialize(port, api)
        @port = port
        @server = TCPServer.new('localhost', port)
        @db = Database.new()
        @rcs = @db.getCollection()
        @api = api
    end
    def run
        while (session = @server.accept)
            if session.gets =~ /GET (.*) HTTP/
                case $1
                when /^\/$/
                    session.print "HTTP/1.1 200/OK\r\nContent-type: text/html\r\n\r\n"
                    session.print showDiff
                    session.close
                when /^\/main\.css$/
                    file = File.open('webstuff/main.css')
                    session.print file.read
                    session.close
                    file.close
                when /^\/icons\.png$/
                    file = File.open('webstuff/icons/icons.png', 'rb')
                    session.write file.read
                    session.close
                    file.close
                end
            end
        end
    end
    def showDiff 
        rc = @rcs.find_one()
        puts rc.inspect()
        if rc['diff'] =~ /diff=(\d+)&oldid=(\d+)/
            curid  = $1
            previd = $2
        end
        htmldiff = @api.getDiff(rc['page'],curid, previd)

        controller = ShowDiffController.new(rc['diff'], htmldiff, rc['page'])
        @rcs.remove({'diff' => rc['diff']})
        return controller.generateHtml
    end
end

