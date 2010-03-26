require 'rubygems'
require 'sequel'

class Database
    # connect with DB
    def initialize
        @db = Sequel.sqlite 'schrader.db' 
        createRcTable
    end
    
    # create an rcs table if it doesn't exist
    def createRcTable
        @db.create_table? :rcs do
            primary_key :id
            String :page
            String :flags
            String :diff
            String :htmldiff
            String :user
            Integer :bytes
            Fixnum :summary
            DateTime :created_at
            TrueClass :reviewed
        end
        @rcs = @db[:rcs]
    end
    # Drops the Rc table and creates it again
    def resetRc
        @db.drop_table(:rcs)
        createRcTable
    end

    # inserts an RC
    def insertRc(page, flags, diff, user, bytes, summary, htmldiff)
        @rcs.insert(:page => page, 
                    :flags => flags, 
                    :diff => diff, 
                    :user => user, 
                    :bytes => bytes, 
                    :created_at => Time.new.to_i,
                    :reviewed => 0,
                    :htmldiff => htmldiff
                   )
    end

    # Retrieves the first unreviewe rc
    def retrieveRc
        rc = @rcs.filter(:reviewed => 0).order(:created_at).first
        rc.update(:reviewed => 1)
        return rc
    end
    def reviewedRc(id)
        @rcs.filter(:id => id).update(:reviewed => true)
    end
    # returns the number of Rcs
    def countRcs
        return @rcs.count
    end
end
