require 'net/http'
require 'uri'
require 'json'

##########################################
# Set variables
##########################################

cn = ''
$accountname = ''
$passwd = 'hoge'
$rest_key = ''
parent_og = ''

##########################################
# Define a method to perform Delete or Get 
##########################################

def uem_req(name, api_uri, bodydata)

  uri = URI.parse(api_uri)

  name = Net::HTTP::Post.new(uri.request_uri)

  name.basic_auth($accountname, $passwd ) 
  name.add_field('aw-tenant-code', $rest_key )
  name.add_field('Accept','application/json' )

  name.set_form_data(bodydata)
 
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.start {|i| i.request(name) }

end

##########################################
# Perform a Get and parse the response to get a specified organization group
##########################################

api = 'https://as' + cn + '.awmdm.jp/API/system/groups/' + parent_og
puts api
bdt = { "Name": "String", "GroupId": "String",  "LocationGroupType": "Container", "Country": "Japan", "Locale": "ja-jp", "AddDefaultLocation": "true", "Devices": "0", "EnableRestApiAccess": false, "Timezone": 13 }

uem_req('new_og', api, bdt)


