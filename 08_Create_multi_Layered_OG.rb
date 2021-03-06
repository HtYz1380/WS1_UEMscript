#
# Requiring Liburaries
# 

require 'net/http'
require 'uri'
require 'json'
require "csv"

#
# Set variables
#

as = '' # enter your API server hostname
$accountname = '' # enter your administrative account name
$passwd = '' # enter your administrative account password
$rest_key = '' # enter the API key 

$ary = CSV.read("td7.csv") # set a csv data file
$params = $ary.shift

#
# Method to search an Organization Group
#

def src_org(name ,meth, api_uri)

  uri = URI.parse(api_uri)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  name = Net::HTTP::Get.new(uri.request_uri)

  name.basic_auth($accountname, $passwd ) 
  name.add_field('aw-tenant-code', $rest_key )
  name.add_field('Accept','application/json' )

  res = http.request(name)
  # puts res.code, res.msg

  yield(res)

end

#
# Method to create an Organiztion Group
#

def cre_org(name, api_uri, bodydata)

  uri = URI.parse(api_uri)

  name = Net::HTTP::Post.new(uri.request_uri)

  name.basic_auth($accountname, $passwd )
  name.add_field('aw-tenant-code', $rest_key )
  name.add_field('Accept','application/json' )

  name.set_form_data(bodydata)

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  hentou = http.start {|h| h.request(name) }
  
  puts Time.new.to_s + " GID " + bodydata["GroupId"] + " "+ hentou.body

end

# 
# Process the given CSV data
# 

$params.pop(1)

$ary.each do |i|

  a = !i[7]
  b = i[8].to_i
  c = i[9]

  i.pop(3)
  i.push(a,b,c)

end

# 
# Refraining creation of Organization Group under designated OG's...
# 

$ary.each do |newog|

  # Converting Parent values to an internal ID on the AirWatch DB...
  api = 'https://' + as + '/API/system/groups/search?groupid=' + newog[9]

  src_org('get_cogs','Get',api) { |res| 

    hash = JSON.parse(res.body)
    da =  hash["LocationGroups"]

  parent_og = da[0]["Id"]["Value"]
  
  # Create a new OG by using post method...
  api = 'https://' + as + '/API/system/groups/' + parent_og.to_s

  na = [$params, newog[0..8]].transpose
  bdt = Hash[*na.flatten]

  cre_org('new_og', api, bdt)
  }

end

# D.L.
