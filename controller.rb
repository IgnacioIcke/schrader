require 'erb'
require 'templates'

# This class represents a general controller (MVC paradigm). It is responsible
# for making the binding between the templates and the data.
class Controller
    # erb binding
    def getBinding
        binding
    end
    # binds the templates with the data
    # [_headAndFooter_] Determines if TemplateHeader and TemplateFooter should
    # be included.
    def generateHtml(headAndFooter = true)
        headerhtml = ERB.new(TemplateHeader)
        footerhtml = ERB.new(TemplateFooter)
        rhtml = ERB.new(@template)
        if headAndFooter
            html = headerhtml.result(getBinding)+rhtml.result(getBinding)+footerhtml.result(getBinding) 
        else
            html = rhtml.result(getBinding)
        end
        return html
    end
end

# Controller for the ShowDiff action

class ShowDiffController < Controller
    # [_site_] Site of the project (ej: http://en.wikipedia.org)
    # [_isAdmin_] _True_ if the user is an admin
    # [_difflink_] Tink to the diff
    # [_htmldiff_] Table with the diff displayed
    # [_page_] Page the to what the diff is a change of
    # [_user_] User who edited the page
    def initialize(site, isAdmin, difflink, htmldiff, page, user)
        @difflink = difflink
        @htmldiff = htmldiff
        @page     = page
        @template = TemplateDiff
        @site     = site
        @user     = user
        @isAdmin  = isAdmin
    end
end
