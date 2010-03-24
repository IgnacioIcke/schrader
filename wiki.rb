require 'rubygems'
require 'rbmediawiki'


class Mediawiki
    def initialize(username, password, apiurl)
        @api = Api.new(nil, nil, username, nil, apiurl)
        @api.login(password)
    end
    def getDiff(page, curid, previd)
        result = @api.query_prop_revisions(page, nil, 1, curid, nil,nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, previd)
        return result['query']['pages']['page']['revisions']['rev']['diff']['content']
    end
end
