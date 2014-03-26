#!/usr/bin/env ruby
#
# A simple script to:
#   1. Add a new domain
#   2. Populate an A record with the server
#   3. Populate CNAME's of Google Apps

#--------------------------------------------------------------------------------------
require 'open-uri'
require 'json'
Dir[File.dirname(__FILE__) + '/lib/*.rb'].each {|file| require file }

#--------------------------------------------------------------------------------------
opts = Trollop::options do
  version "add-domain.rb 0.1 (c) 2014 Jeremy Turner"
  banner <<-EOS
add-domain.rb is a simple script to:
1. Add a new domain
2. Populate an A record pointing to the droplet
3. Populate CNAME's of Google Apps

Usage:
       add-domain.rb --domain example.com --ip 12.34.56.78

EOS
  opt :domain, "Domain name (excluding www)", :type => :string  # string --name <s>, default nil
  opt :ip,     "IP address of the droplet",   :type => :string  # string --name <s>, default nil
end

Trollop::die :domain, "must be valid" if opts[:domain] == nil
Trollop::die :ip,     "must be valid" if opts[:ip]     == nil

# Strip a leading www
opts[:domain] = opts[:domain].gsub(/^www\./, '')

# send a simple http get
def send_url(url)
  # debug - puts "trying #{url}"
  result = JSON.parse(URI.parse(url).read)
  puts "#{result['status']} #{result['message']}" if result['status'] == 'ERROR'
end

front = "https://api.digitalocean.com/"

keys = {
  :client_id => ENV['DO_CLIENT_ID'],
  :api_key => ENV['DO_API_KEY'],
}
#--------------------------------------------------------------------------------------

host = [
  {
  	:name => opts[:domain],
  	:ip_address => opts[:ip]
  }
]

# priority, data
mx = [
  { :record_type => 'MX', :priority => '10', :data => 'ASPMX.L.GOOGLE.COM.' },
  { :record_type => 'MX', :priority => '20', :data => 'ALT1.ASPMX.L.GOOGLE.COM.' },
  { :record_type => 'MX', :priority => '20', :data => 'ALT2.ASPMX.L.GOOGLE.COM.' },
  { :record_type => 'MX', :priority => '30', :data => 'ASPMX2.GOOGLEMAIL.COM.' },
  { :record_type => 'MX', :priority => '30', :data => 'ASPMX3.GOOGLEMAIL.COM.' },
  { :record_type => 'MX', :priority => '30', :data => 'ASPMX4.GOOGLEMAIL.COM.' },
  { :record_type => 'MX', :priority => '30', :data => 'ASPMX5.GOOGLEMAIL.COM.' }
]

# data, name
cname = [
  { :record_type => 'CNAME', :data => 'ghs.googlehosted.com.', :name => 'calendar' },
  { :record_type => 'CNAME', :data => 'ghs.googlehosted.com.', :name => 'docs' },
  { :record_type => 'CNAME', :data => 'ghs.googlehosted.com.', :name => 'mail' },
  { :record_type => 'CNAME', :data => 'ghs.googlehosted.com.', :name => 'sites' },
  { :record_type => 'CNAME', :data => 'ghs.googlehosted.com.', :name => 'start' },
  { :record_type => 'CNAME', :data => opts[:domain] + '.', :name => 'www' }
]

# data, name
a = [

]

# Setup the new domain
host.each do|n|

  # Construct the base part of the URL
  url = front + 'domains/new?'

  # Merge together the keys along with the domain info
  n.merge(keys).each_pair {|key,value| url += "&#{key}=#{value}"}

  # Send the URL
  send_url(url)
end


# Populate the DNS records
(mx + cname + a).each do|n|

  # Construct the base part of the URL
  url = front + 'domains/' + opts[:domain] + '/records/new?'

  # Merge together the keys along with the domain info
  keys.merge(n).each_pair {|key,value| url += "&#{key}=#{value}"}

  # Send the URL
  send_url(url)
end
