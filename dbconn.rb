require 'rubygems'
require 'mongo'

# Class to work with a mongo database

class Database  
    #connect to the DB
    def initialize
        db = Mongo::Connection.new("localhost", 27017).db("schrader")
        @rcs = db.collection("Rc")
        @rcs.create_index("created_at")
    end
    #Get the collection of RCs
    def getCollection
        return @rcs
    end
    #Reset the DB
    def reset
        m = Mongo::Connection.new # (optional host/port args)
        m.drop_database('schrader')
    end
end
