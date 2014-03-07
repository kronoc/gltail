# gl_tail.rb - OpenGL visualization of your server traffic
# Copyright 2007 Erlend Simonsen <mr@fudgie.org>
#
# Licensed under the GNU General Public License v2 (see LICENSE)
#

# Parser which handles access_logs in combined format from Forge
class ForgeParser < Parser
  def parse( line )
    _, host, date, date2, time, url, status, size, foo, useragent, machine, user = /(.+\d) - - (\[([^\]]+)\]) (\d+) \"(.+?)\" (\d+) (\d+) \"(-)\" \"(.+?)\" (.+\d) \"(.+?)\"/.match(line).to_a

    if host
      method, url, http_version = url.split(" ")
      url = method if url.nil?
      url, parameters = url.split('?')
	
      email, app, app_type, org, loc, country = user.split(" ")
            
      add_activity(:block => 'sites', :name => server.name, :size => size.to_i) # Size of activity based on size of request
      add_activity(:block => 'urls', :name => url)
      add_activity(:block => 'users', :name => app, :size => size.to_i + time.to_i)
      add_activity(:block => 'hosts', :name => machine)

      type = 'page'
      add_activity(:block => 'content', :name => method)
      add_activity(:block => 'status', :name => status, :type => 3) # don't show a blob

      add_activity(:block => 'warnings', :name => "#{status}: #{url}") if status.to_i > 400

      # Events to pop up
      add_event(:block => 'info', :name => "Imports", :message => "Import...", :update_stats => true, :color => [1.5, 1.0, 0.5, 1.0]) if method == "POST" && url.include?('import')
      add_event(:block => 'info', :name => "Interlinking", :message => "Interlinking...", :update_stats => true, :color => [1.5, 0.0, 0.0, 1.0]) if method == "POST" && url.include?('/mrss')
      add_event(:block => 'info', :name => "Deletes", :message => "Deletes...", :update_stats => true, :color => [1.0, 1.0, 1.0, 1.0]) if method == "DELETE"
    end
  end
end
