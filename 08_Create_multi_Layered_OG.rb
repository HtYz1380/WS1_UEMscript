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

cn = ''
$accountname = ''
$passwd = ''
$rest_key = ''

$ary = CSV.read("hogehoge.csv") # set a csv data file
$params = $ary.shift

#
# Method to search an Organization Group
#

def uem_req1(name ,meth, api_uri)

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

def uem_req(name, api_uri, bodydata)

  uri = URI.parse(api_uri)

  name = Net::HTTP::Post.new(uri.request_uri)

  name.basic_auth($accountname, $passwd )
  name.add_field('aw-tenant-code', $rest_key )
  name.add_field('Accept','application/json' )

  name.set_form_data(bodydata)

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.start {|h| h.request(name) }

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

$ary.each do |iii|

  # Converting Parent values to an internal ID on the AirWatch DB...
  api = 'https://as' + cn + '.awmdm.com/API/system/groups/search?groupid=' + iii[9]

  uem_req1('get_cogs','Get',api) { |res| 

    hash = JSON.parse(res.body)
    da =  hash["LocationGroups"]

  parent_og = da[0]["Id"]["Value"]
  
  # Create a new OG by using post method...
  api = 'https://as' + cn + '.awmdm.com/API/system/groups/' + parent_og.to_s

  na = [$params, iii[0..8]].transpose
  bdt = Hash[*na.flatten]

  uem_req('new_og', api, bdt)
  }

end
