require 'rubygems'
require 'sequel'

class Database
    # connect with DB
    def initialize
        @db = Sequel.sqlite 'schrader.db' 
        createRcTable
        createWLTable
    end
    
    # create a Whitelist Table if it doesn't exist
    def createWLTable
        @db.create_table? :wl do
            primary_key :id
            String :user
        end
        @wl = @db[:wl]
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
        if @wl.filter(:user => user).first
            reviewed = 1
        else
            reviewed = 0
        end
        @rcs.insert(:page => page, 
                    :flags => flags, 
                    :diff => diff, 
                    :user => user, 
                    :bytes => bytes, 
                    :created_at => Time.new.to_i,
                    :reviewed => reviewed,
                    :htmldiff => htmldiff
                   )
    end
    
    # Adds an user to the Whitelist
    # [_user_] user to be inserted
    def addWL(user)
        @wl.insert(:user => user)
        #all his changes are reviewed
        @rcs.filter(:user => user).update(:reviewed => 1)
    end

    # Retrieves the first unreviewe rc
    def retrieveRc
        rc = @rcs.filter(:reviewed => 0).order(:created_at).first
        if (rc)
            rc.update(:reviewed => 1)
        end
        return rc
    end
    def reviewedRc(id)
        @rcs.filter(:id => id).update(:reviewed => 1)
    end
    # returns the number of Rcs
    def countRcs
        return @rcs.filter(:reviewed => 0).count
    end
end
