require 'erb'
require 'templates'

# This class represents a general controller (MVC paradigm). It is responsible
# for making the binding between the templates and the data.
class Controller
    # erb binding
    def getBinding
        binding
    end
    # binds the templates with the data including header and footer
    def generateHtml
        headerhtml = ERB.new(TemplateHeader)
        footerhtml = ERB.new(TemplateFooter)
        rhtml = ERB.new(@template)
        html = headerhtml.result(binding)+rhtml.result(binding)+footerhtml.result(binding) 
        return html
    end
    # binds the templates with the data without header and footer
    def generateRawHtml
        rhtml = ERB.new(@template)
        html = rhtml.result(getBinding)
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
    def initialize(site, isAdmin, difflink, htmldiff, page, user, summary, numdiffs, log)
        @difflink = difflink
        @htmldiff = htmldiff
        @page     = page
        @template = TemplateDiff
        @site     = site
        @user     = user
        @isAdmin  = isAdmin
        @numdiffs = numdiffs
        @log      = log
        @summary  = summary
    end
end

# Controller for the ShowLog action
class ShowLogController < Controller
    def initialize(numdiffs, log)
        @numdiffs = numdiffs
        @log = log
        @template = TemplateLog
    end
end

# Controller for the ShowLog action
class ShowLogSnippetController < Controller
    def initialize(numdiffs, log)
        @numdiffs = numdiffs
        @log = log
        @template = TemplateLogSnippet
    end
end
