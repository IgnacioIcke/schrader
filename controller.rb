require 'erb'
require 'templates'

class Controller
    def getBinding
        binding
    end
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

class ShowDiffController < Controller
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
