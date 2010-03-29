#Contains templates for the actions

require "erb"
require 'rubygems'
require 'r18n-desktop'

Configuration = YAML::load(File.open("config.yml"))

if Configuration.key? 'language' 
    lang = Configuration['language']
else
    lang = 'en'
end

R18n.from_env 'i18n/', lang
include R18n::Helpers

class String
    def escapejs
        self.gsub(/'/, "\\\\'")
    end
end

TemplateHeader = %{
    <html><head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <link rel="shortcut icon" href="/favicon.ico" />
    <link rel="stylesheet" href="/main.css" type="text/css" media="screen" />
    <script type="text/javascript" src="http://code.jquery.com/jquery-1.4.2.min.js"></script>

    </head><body>}.gsub(/^  /, '')

TemplateFooter = %{
    <div class="footer">
    <a href="http://github.com/IgnacioIcke/schrader" target='_blank'><img src="favicon.ico" />chrader</a>
    </div>
    </body></html>
}

TemplateDiff = %{
    <script type="text/javascript">
        $(document).ready(function()
        {
            var refreshId = setInterval(function()
            {
                $('#log').load('/log');
            }, 3000);
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
                url: '/rollback?user=<%= @user.escapejs %>&page=<%= @page.escapejs %>'
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
                url: '/whitelist?user=<%= @user.escapejs %>',
                success: function(){next();}
            }); 
        }
        function block(){
            window.open('<%= @site %>/wiki/Special:Block/<%= @user.escapejs %>');
        }
        function deleteArt(){
            window.open('<%= @site %>/w/index.php?title=<%= @page.escapejs %>&action=delete');
        }
        function view(){
            window.open('<%= @site %>/wiki/<%= @page.escapejs %>'); 
        }
        function edit(){
            window.open('<%= @site %>/w/index.php?title=<%= @page.escapejs %>&action=edit');
        }
        function userPage(){
            window.open('<%= @site %>/wiki/User:<%= @user.escapejs %>');
        }
        function talk(){
            window.open('<%= @site %>/wiki/User Talk:<%= @user.escapejs %>');
        }
        function newMessage(){
            window.open('<%= @site %>/w/index.php?title=User_Talk:<%= @user.escapejs %>&action=edit&section=new');
        }
        function cleanRc(){
            $.ajax({
                url: '/cleanRc'
            }); 
            next();
        }
    </script>
    <div id="log">
    <%= ShowLogSnippetController.new(@numdiffs, @log).generateRawHtml %>
    </div>
    <div class="buttons">
    <button class="icon icon-next" onClick="next()" title="<%= t.next %> (space)"></button>
    <button class="icon icon-revert" onClick="rollback()" title="<%= t.rollback %> (x)"></button>
    <!--<button class="icon icon-revertwarn" onClick="revertAndWarn()" title="<%= t.rollbackandwarn %> (a)"></button>
    <button class="icon icon-warn" onClick="warn()" title="<%= t.warn %> (w)" ></button>-->
    <button class="icon icon-block" onClick="block()" title="<%= t.block %> (b)"></button>
    <button class="icon icon-delete" onClick="deleteArt()" title="<%= t.delete %> (d)"></button>
    <button class="icon icon-whitelist" onClick="whitelist()" title="<%= t.whitelist %> (l)"></button>
    <button class="icon icon-view" onClick="view()" title="<%= t.viewpage %> (v)"></button>
    <button class="icon icon-edit" onClick="edit()" title="<%= t.edit %> (e)" ></button>
    <button class="icon icon-user" onClick="userPage()" title="<%= t.userpage %> (u)"></button>
    <button class="icon icon-talk" onClick="talk()" title="<%= t.usertalk %> (t)"></button>
    <button class="icon icon-newmsg" onClick="newMessage()" title="<%= t.newmessage %> (m)"></button>
    </div>
    <div id="titlediv">
        <h1 id="title" onClick="view()"><%= @page %></h1>
        <div id="summary"><em><%= @summary %></em></div>
        <a href="<%= @site %>/wiki/User:<%= @user %>" target='_blank'><%= @user %></a> (<a href="<%= @site %>/wiki/User_Talk:<%= @user %>" target='_blank'><%= t.talk %></a>|<a href="<%= @site %>/wiki/Special:Contributions/<%= @user %>" target='_blank'><%= t.contributions %></a>)
    </div>
    <% if @newpage %>
        <div class="newpage">
        <%= @htmldiff %>
        </div>
    <% else %>
        <center>
        <table class="diff">
        <col class="diff-marker"/>
        <col class="diff-content"/>
        <col class="diff-marker"/>
        <col class="diff-content"/>
        <%= @htmldiff %></table>
        </center>
    <% end %>
}

#When there are no rcs
TemplateLog = %{
    <script type="text/javascript">
        function cleanRc(){
            return true;
        }
        $(document).ready(function()
        {
            var refreshId = setInterval(function()
            {
                $('#log').load('/log');
                if ($('#rcCount').text != 0){
                    location.href = '/';
                }
            }, 3000);
        });
    </script>
    <div id="log">
    <%= ShowLogSnippetController.new(@numdiffs, @log).generateRawHtml %>
    </div>
    <div id="titlediv">
    <h1 id="title"><%= t.noRcs %></h1>
    <p><%= t.wait %></p>
    </div>
    <div id="waiting"></div>
}


#Shows the log and the number of unreviewed RCs
TemplateLogSnippet = %{
    <div id ="status"><%= t.unreviewed %><span id="rcCount"><%= @numdiffs.to_s %></span><a href="#"><img src="removerc.png" onclick="cleanRc()" title="<%= t.clean %>"/></a></div>
    <ul id ="loglines">
        <% if @log %>
            <% @log.each do |logline|%>
                <li><%= logline[:message] %></li>
            <% end %>
        <% end %>
    </ul>
}
