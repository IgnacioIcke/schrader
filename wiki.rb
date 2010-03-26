require 'rubygems'
require 'rbmediawiki'
require 'erb'

# This class is a wrapper of rbmediawiki

class Mediawiki
    # sings in in mediawiki
    # [_username_] The user's name
    # [_password_] The user's password
    # [_apiurl_] Api's URL
    def initialize(username, password, apiurl)
        @api = Api.new(nil, nil, username, nil, apiurl)
        @api.login(password)
    end
    # Gets a diff
    # [_page_] Page 
    # [_previd_] previous id of the diff
    # [_curid_] current id of the diff
    def getDiff(page, previd, curid)
        result = @api.query_prop_revisions(page, nil, 1, curid, nil,nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, previd)
        return result['query']['pages']['page']['revisions']['rev']['diff']['content']
    end
    # Rollback in a page
    # [_user_] User to revert
    # [_page_] Page in which we do the rollback
    def rollback(user, page)
        result = @api.query_prop_revisions(page, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, "rollback" )
        token = result['query']['pages']['page']['revisions']['rev']['rollbacktoken']
        result = @api.rollback(page, user, token, t.rollback + " [[special:contributions/#{user}|#{user}]]")
        if result.key? 'error'
            return false
        else 
            return true
        end
    end
end
