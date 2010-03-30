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

def loadTemplate(filename)
    editWLFile = File.open(filename)
    template = editWLFile.read
    editWLFile.close
    return template
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

TemplateEditWL = loadTemplate('templates/editWL.rhtml')

TemplateDiff = loadTemplate('templates/diff.rhtml')

#When there are no rcs
TemplateLog = %{
    <script type="text/javascript">
        function clearRc(){
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
    <script type="text/javascript">
    $(document).ready(function()
    {
        $('.icondelete').hover(function(){
            $(this).attr('src','/remove.png');
        }, function(){
            $(this).attr('src','/remove-off.png');
        });
    });
    </script>

    <div id ="status"><%= t.unreviewed %><span id="rcCount"><%= @numdiffs.to_s %></span><a href="#"><img class="icondelete" src="remove-off.png" onclick="clearRc()" title="<%= t.clean %>"/></a></div>
    <ul id ="loglines">
        <% if @log %>
            <% @log.each do |logline|%>
                <li><%= logline[:message] %></li>
            <% end %>
        <% end %>
    </ul>
}
