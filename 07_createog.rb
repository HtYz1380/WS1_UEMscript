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
parent_og = '' # numeric number 

$ary = CSV.read("") # testdata csv filename
$params = $ary.shift

#
# Method to create a post request
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
# Perform a Get and parse the response to get a specified organization group
#

api = 'https://as' + cn + '.awmdm.jp/API/system/groups/' + parent_og

#

$ary.each do |i|

  a = !i[7]
  b = i[8].to_i

  i.pop(2)
  i.push(a,b)

  # create a body data to post 
  row = CSV::Row.new($params,i)
  puts row.to_hash.to_json
  bdt = row.to_hash

  uem_req('new_og', api, bdt)

end
