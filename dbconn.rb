require 'rubygems'
require 'sequel'

class Database
    # connect with DB
    def initialize
        @db = Sequel.sqlite 'schrader.db' 
        createRcTable
        createWLTable
        createLogTable
    end
    
    # create a Whitelist Table if it doesn't exist
    def createWLTable
        @db.create_table? :wl do
            primary_key :id
            String :user
        end
        @wl = @db[:wl]
    end

    # create a Logger Table if it doesn't exist
    def createLogTable
        @db.create_table? :log do
            primary_key :id
            String :message
            DateTime :created_at
        end
        @log = @db[:log]
    end

    # create an rcs table if it doesn't exist
    def createRcTable
        @db.create_table? :rcs do
            primary_key :id
            String :page
            String :flags
            String :diff
            Integer :rcid 
            String :htmldiff
            String :user
            String :summary
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

    #clean Rc: set us up to date
    def clearRc
        @rcs.update(:reviewed => 1)
    end

    #clean WL: delete this list
    def clearWL
        @wl.delete
    end

    # Drops the Rc table and creates it again
    def resetLog
        @db.drop_table(:log)
        createLogTable
    end

    # inserts an RC
    def insertRc(page, flags, diff, rcid, user, summary, htmldiff)
        if @wl.filter(:user => user).first
            reviewed = 1
        else
            reviewed = 0
        end
        @rcs.insert(:page => page, 
                    :flags => flags, 
                    :diff => diff, 
                    :user => user, 
                    :summary => summary,
                    :created_at => Time.new.to_i,
                    :reviewed => reviewed,
                    :htmldiff => htmldiff,
                    :rcid => rcid
                   )
    end

    # Adds a message to the log
    def insertLog(message)
        @log.insert(:message => message,
                    :created_at => Time.new.to_i)
    end

    # Retrieve last log entries
    def retrieveLog(num)
        return @log.reverse_order(:created_at).limit(num)
    end
    
    # Adds an user to the Whitelist
    # [_user_] user to be inserted
    def addWL(user)
        user.chomp!
        if not @wl.filter(:user => user).first and not user =~ /^\s*$/
            @wl.insert(:user => user)
            #all his changes are reviewed
            @rcs.filter(:user => user).update(:reviewed => 1)
        end
    end

    # Removes an user from the whitelist
    # [_id_] user to be inserted
    def removeFromWL(id)
        @wl.filter(:id => id).delete
    end

    # Retrieves the full whitelist
    def getWL
        return @wl.order(:user)
    end


    # Retrieves the first unreviewe rc
    def retrieveRc
        rc = @rcs.filter(:reviewed => 0).order(:created_at).first
        if (rc)
            rc.update(:reviewed => 1)
        end
        return rc
    end

    # Marks a diff as reviewed
    # [_id_] id of the diff
    def reviewedRc(id)
        @rcs.filter(:id => id).update(:reviewed => 1)
    end

    # returns the number of Rcs
    def countRcs
        return @rcs.filter(:reviewed => 0).count
    end
end
