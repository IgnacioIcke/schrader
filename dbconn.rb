require 'rubygems'
require 'mongo'

class Database  
    def initialize
        db = Mongo::Connection.new("localhost", 27017).db("schrader")
        @rcs = db.collection("Rc")
        @rcs.create_index("created_at")
    end
    def getCollection
        return @rcs
    end
    #empty the db
    def reset
        m = Mongo::Connection.new # (optional host/port args)
        m.drop_database('schrader')
    end
end
