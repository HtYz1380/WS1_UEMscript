require 'net/http'
require 'uri'
require 'json'

#
# Set variables
#

# REST API endpoint FQDN
apihost = ''

# Group ID on the Admin Console
gid = ''

# Account name that has access right to the API Service
$accountname = ''

# Password of obove Admin Account
$passwd = ''

# Rest API Key found on the Admin Console
$rest_key = ''

#
# Define a method to perform Get 
#

def uem_req(name ,meth, api_uri)

  uri = URI.parse(api_uri)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  if meth == 'Get' 
    name = Net::HTTP::Get.new(uri.request_uri)
  end

  name.basic_auth($accountname, $passwd ) 
  name.add_field('aw-tenant-code', $rest_key )
  name.add_field('Accept','application/json' )

  res = http.request(name)

  yield(res)

end

#
# Convert a Group ID to its Internal numeric ID
#

api = 'https://' + apihost + '/API/system/groups/search?groupid=' + gid

uem_req('get_internal_id','Get',api) { |res|

  body_hash = JSON.parse(res.body)
  loc_group =  body_hash["LocationGroups"]

  internalid = loc_group[0]["Id"]["Value"]

  puts internalid
}
