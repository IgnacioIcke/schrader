#Contains templates for the actions

require "erb"
require 'rubygems'
require 'r18n-desktop'

R18n.from_env 'i18n/'
include R18n::Helpers

TemplateHeader = %{
    <html><head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <link rel="shortcut icon" href="/favicon.ico" />
    <link rel="stylesheet" href="/main.css" type="text/css" media="screen" />
    <script type="text/javascript" src="http://code.jquery.com/jquery-1.4.2.min.js"></script>

    </head><body>}.gsub(/^  /, '')

TemplateFooter = %{
    <div class="footer">
    <a href="http://github.com/IgnacioIcke/schrader"><img src="favicon.ico" />chrader</a>
    </div>
    </body></html>
}

TemplateDiff = %{
    <script type="text/javascript">
        $(document).ready(function()
        {
            $(document).keydown(function(event) {
                switch (event.keyCode) {
                    case 32:
                        next();
                    break;
                    case 88:
                        rollback();
                    break;
                    case 87:
                        warn();
                    break;
                    case 65:
                        revertAndWarn();
                    break;
                    case 76:
                        whitelist();
                    break;
                    case 66:
                        block();
                    break;
                    case 68:
                        deleteArt();
                    break;
                    case 86:
                        view();
                    break;
                    case 69:
                        edit();
                    break;
                    case 85:
                        userpage();
                    break;
                    case 84:
                        talk();
                    break;
                    case 77:
                        newMessage();
                    break;
                }
                return false;
            });
        });
        function next(){
            location.href = '/';
        }
        function rollback(){
            $.ajax({
                url: '/rollback?user=<%= @user %>&page=<%= @page %>'
            }); 
        }
        function warn(){
        }
        function revertAndWarn(){
            rollback();
            warn();
        }
        function whitelist(){
            $.ajax({
                url: '/whitelist?user=<%= @user %>'
            }); 
            next();
        }
        function block(){
            window.open('<%= @site %>/wiki/Special:Block/<%= @user %>');
        }
        function deleteArt(){
            window.open('<%= @site %>/w/index.php?title=<%= @page %>&action=delete');
        }
        function view(){
            window.open('<%= @site %>/wiki/<%= @page %>'); 
        }
        function edit(){
            window.open('<%= @site %>/w/index.php?title=<%= @page %>&action=edit');
        }
        function userPage(){
            window.open('<%= @site %>/wiki/User:<%= @user %>');
        }
        function talk(){
            window.open('<%= @site %>/wiki/User Talk:<%= @user %>');
        }
        function newMessage(){
            window.open('<%= @site %>/w/index.php?title=User_Talk:<%= @user %>&action=edit&section=new');
        }
    </script>
    <%= ShowLogController.new(@numdiffs, @log).generateRawHtml %>
    <div class="buttons">
    <button class="icon icon-next" onClick="next()" title="<%= t.next %> (space)"></button>
    <button class="icon icon-revert" onClick="rollback()" title="<%= t.rollback %> (x)"></button>
    <button class="icon icon-revertwarn" onClick="revertAndWarn()" title="<%= t.rollbackandwarn %> (a)"></button>
    <button class="icon icon-warn" onClick="warn()" title="<%= t.warn %> (w)" ></button>
    <button class="icon icon-block" onClick="block()" title="<%= t.block %> (b)"></button>
    <button class="icon icon-delete" onClick="deleteArt()" title="<%= t.delete %> (d)"></button>
    </div>
    <div class="buttons">
    <button class="icon icon-whitelist" onClick="whitelist()" title="<%= t.whitelist %> (l)"></button>
    <button class="icon icon-view" onClick="view()" title="<%= t.viewpage %> (v)"></button>
    <button class="icon icon-edit" onClick="edit()" title="<%= t.edit %> (e)" ></button>
    <button class="icon icon-user" onClick="userPage()" title="<%= t.userpage %> (u)"></button>
    <button class="icon icon-talk" onClick="talk()" title="<%= t.usertalk %> (t)"></button>
    <button class="icon icon-newmsg" onClick="newMessage()" title="<%= t.newmessage %> (n)"></button>
    </div>
    <center>
    <h1><%= @page %></h1>
    <span class="centered"><a href="<%= @site %>/wiki/User:<%= @user %>"><%= @user %></a> (<a href="<%= @site %>/wiki/User_Talk:<%= @user %>"><%= t.talk %></a>|<a href="<%= @site %>/wiki/Special:Contributions/<%= @user %>"><%= t.contributions %></a>) </span>
    <table class="diff">
    <col class="diff-marker"/>
    <col class="diff-content"/>
    <col class="diff-marker"/>
    <col class="diff-content"/>
    <%= @htmldiff %></table>
    <center>
}

#Shows the log and the number of unreviewed RCs
TemplateLog = %{
    <script type="text/javascript">
        $(document).ready(function()
        {
            var refreshId = setInterval(function()
            {
                $('#log').load('/log');
            }, 3000);
        });
    </script>
    <div id="log">
    <div id ="status"><%= t.unreviewed %><span id="rcCount"><%= @numdiffs.to_s %></span></div>
    <ul id ="loglines">
        <% if @log %>
            <% @log.each do |logline|%>
                <li><%= logline[:message] %></li>
            <% end %>
        <% end %>
    </ul>
    </div>
}
