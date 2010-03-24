require "erb"

TemplateHeader = %{
    <html><head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <link rel="stylesheet" href="/main.css" type="text/css" media="screen" />
    <script type="text/javascript" src="http://code.jquery.com/jquery-1.4.2.min.js"></script>

    </head><body>}.gsub(/^  /, '')

TemplateFooter = %{
    <div class="footer">
    <a href="http://github.com/IgnacioIcke/schrader">Schrader</a>
    </div>
    </body></html>
}

TemplateDiff = %{
    <script type="text/javascript">
        function rollback(){
            $.ajax({
                url: '/rollback?user=<%= @user %>&page=<%= @page %>'
            }); 
        }
    </script>
    <div class="buttons">
    <button class="icon icon-next" onClick="location.href = '/'" title="Next"></button>
    <button class="icon icon-revert" onClick="rollback()" title="rollback"></button>
    <button class="icon icon-revertwarn" onClick="rollbackwarn()"></button>
    <button class="icon icon-warn" onClick="location.href = '/'"></button>
    <button class="icon icon-block" onClick="location.href = '/'"></button>
    <button class="icon icon-delete" onClick="location.href = '/'"></button>
    </div>
    <div class="buttons">
    <button class="icon icon-whitelist" onClick="location.href = '/'"></button>
    <button class="icon icon-view" onClick="window.open('<%= @site %>/wiki/<%= @page %>')" title="View page"></button>
    <button class="icon icon-edit" onClick="window.open('<%= @site %>/w/index.php?title=<%= @page %>&action=edit')" title="Edit" ></button>
    <button class="icon icon-user" onClick="window.open('<%= @site %>/wiki/User:<%= @user %>')" title="User page"></button>
    <button class="icon icon-talk" onClick="window.open('<%= @site %>/wiki/User Talk:<%= @user %>')" title="User talk"></button>
    <button class="icon icon-newmsg" onClick="window.open('<%= @site %>/w/index.php?title=User_Talk:<%= @user %>&action=edit&section=new')" title="New message"></button>
    </div>
    <center>
    <h1><%= @page %></h1>
    <span class="centered"><a href="<%= @site %>/wiki/User:<%= @user %>"><%= @user %></a> (<a href="<%= @site %>/wiki/User_Talk:<%= @user %>">talk</a>|<a href="<%= @site %>/wiki/Special:Contributions/<%= @user %>">contributions</a>) </div>
    <table class="diff">
    <col class="diff-marker"/>
    <col class="diff-content"/>
    <col class="diff-marker"/>
    <col class="diff-content"/>
    <%= @htmldiff %></table>
    <center>
}


