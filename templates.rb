require "erb"

TemplateHeader = %{
    <html><head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <link rel="stylesheet" href="/main.css" type="text/css" media="screen" />
    </head><body>}.gsub(/^  /, '')

TemplateFooter = %{
    </body></html>
}

TemplateDiff = %{
    <div class="buttons">
    <div class="icon icon-next"></div>
    <div class="icon icon-revert"></div>
    <div class="icon icon-revertwarn"></div>
    <div class="icon icon-warn"></div>
    <div class="icon icon-block"></div>
    <div class="icon icon-delete"></div>
    </div>
    <div class="buttons">
    <div class="icon icon-whitelist"></div>
    <div class="icon icon-view"></div>
    <div class="icon icon-edit"></div>
    <div class="icon icon-user"></div>
    <div class="icon icon-talk"></div>
    <div class="icon icon-newmsg"></div>
    </div>
    <table class="diff">
    <col class="diff-marker"/>
    <col class="diff-content"/>
    <col class="diff-marker"/>
    <col class="diff-content"/>
    <%= @htmldiff %></table>
}
