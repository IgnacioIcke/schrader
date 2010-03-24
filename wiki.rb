require 'rubygems'
require 'rbmediawiki'


class Mediawiki
    def initialize(username, password, apiurl)
        @api = Api.new(nil, nil, username, nil, apiurl)
        @api.login(password)
    end
    def getDiff(page, previd, curid)
        result = @api.query_prop_revisions(page, nil, 1, curid, nil,nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, previd)
        return result['query']['pages']['page']['revisions']['rev']['diff']['content']
    end
    def rollback(user, page)
        result = @api.query_prop_revisions(page, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, "rollback" )
        puts result
        token = result['query']['pages']['page']['revisions']['rev']['rollbacktoken']
        puts token
        result = @api.rollback(page, user, token, "rollback  #{user}")
        puts result
    end
end
