require 'erb'
require 'templates'

class Controller
    def getBinding
        binding
    end
    def generateHtml
        headerhtml = ERB.new(TemplateHeader)
        footerhtml = ERB.new(TemplateFooter)
        rhtml = ERB.new(@template)
        html = headerhtml.result(getBinding)+rhtml.result(getBinding)+footerhtml.result(getBinding) 
        return html
    end
end

class ShowDiffController < Controller
    def initialize(difflink, htmldiff, page)
        @difflink = difflink
        @htmldiff = htmldiff
        @page     = page
        @template = TemplateDiff
    end
end
