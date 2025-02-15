require 'net/http'
require 'uri'
require 'json'

##########################################
# Set variables
##########################################

# REST API endpoint FQDN
apihost = 'asXXXX.awmdm.com'

# Group ID on the Admin Console(the last numeric number of the URL of your organization details page)
numeric_gid = ''

# Account name that has access right to the API Service
$accountname = ''

# Password of obove Admin Account
$passwd = ''

# Rest API Key found on the Admin Console
$rest_key = ''

##########################################
# Define a method to perform Get 
##########################################

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

##########################################
# Get Child Organization Groups
##########################################

api = 'https://' + apihost + '/API/system/groups/' + numeric_gid + '/children'

uem_req('get_child_orgs','Get',api) { |res|

  $child_orgs = JSON.parse(res.body)

}

##########################################
# Puts the OG names and numeric ids of OG
##########################################

$child_orgs.each do |i|
  puts i["Name"]
  puts i["Id"]["Value"]
  numeric_org_id = i["Id"]["Value"]

    ##########################################
    # Get Android Enterprise setting
    ##########################################

    api2 = 'https://' + apihost + '/API/system/groups/' + numeric_org_id.to_s + '/androidwork'

    uem_req('get_androidwork_setting','Get',api2) { |res2|

    body_hash2 = JSON.parse(res2.body)
    puts body_hash2["ServiceAccountAdminEmail"]

    }

end
