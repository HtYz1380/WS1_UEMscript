# 
# Requiring Liburaries..
# 

require 'net/http'
require 'uri'
require 'json'
require "csv"

#
# Set variables
#

cn = '' # enter your API server hostname
$accountname = '' # enter your administrative account name
$passwd = '' # enter your administrative account password
$rest_key = '' # enter the API key 
$parent_og = '' # enter gid of an organization group, which will be deleted with its descendants

#
# Method to search an Organization Group
#

def uem_req1(name , api_uri)

  uri = URI.parse(api_uri)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  name = Net::HTTP::Get.new(uri.request_uri)

  name.basic_auth($accountname, $passwd ) 
  name.add_field('aw-tenant-code', $rest_key )
  name.add_field('Accept','application/json' )

  res = http.request(name)

  yield(res)

end

#
# Method to delete an Organization Group
#

def uem_req2(name , api_uri)

  uri = URI.parse(api_uri)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  name = Net::HTTP::Delete.new(uri.request_uri)

  name.basic_auth($accountname, $passwd ) 
  name.add_field('aw-tenant-code', $rest_key )
  name.add_field('Accept','application/json' )

  res = http.request(name)

  puts res.msg

end

#
# Convert a given parent GID to a numeric id.
#

api = 'https://' + cn + '/API/system/groups/search?groupid=' + $parent_og

uem_req1('get_cogs',api) { |res| 

  hash = JSON.parse(res.body)
  $a =  hash["LocationGroups"]

}

parent_og = $a[0]["Id"]["Value"]

# 
# get a list of children organization groups.
# 

uri = URI.parse('https://' + cn +'/API/system/groups/' + parent_og.to_s + '/children')
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true

req = Net::HTTP::Get.new(uri.request_uri)

req.basic_auth($accountname, $passwd ) 
req.add_field('aw-tenant-code', $rest_key )
req.add_field('Accept','application/json' )

res = http.request(req)

ary = JSON.parse(res.body)

ary = ary.reverse!
iiii = 0

while iiii < ary.length

  a = ary[iiii]["Id"]["Value"]

  api2 = 'https://' + cn + '/API/system/groups/'+ a.to_s
  puts "Deleting #{ary[iiii]["Name"]}..."
  uem_req2('del_cogs', api2)

  iiii += 1

end  

# D.R.
