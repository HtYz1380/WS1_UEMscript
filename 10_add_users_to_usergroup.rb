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

$ary = CSV.read("testdata.csv")
$line2ikou = $ary.drop(1) # remove first line

#
# Method to search an object by using its name
#

def get_request(name, meth, api_uri)

  uri = URI.parse(api_uri)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.ciphers="DEFAULT:!DH"
  name = Net::HTTP::Get.new(uri.request_uri)

  name.basic_auth($accountname, $passwd )
  name.add_field('aw-tenant-code', $rest_key )
  name.add_field('Accept','application/json' )

  res = http.request(name)
  # puts res.code, res.msg

  yield(res)

end

def post_request(name, api_uri)

  uri = URI.parse(api_uri)

  name = Net::HTTP::Post.new(uri.request_uri)

  name.basic_auth($accountname, $passwd )
  name.add_field('aw-tenant-code', $rest_key )
  name.add_field('Accept','application/json' )

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.ciphers="DEFAULT:!DH"
  hentou = http.start {|h| h.request(name) }

  puts Time.new.to_s + " "+ hentou.body

end


$line2ikou.each do |group_and_user|

  group = group_and_user[0]
  # get usergroupID
  api_to_get_usergroupID = "https://" + as + "/API/system/usergroups/search?groupname=" + group

  get_request('get_usergroup','Get',api_to_get_usergroupID) {|res|
    hashed_response = JSON.parse(res.body)
    usergroup_details = hashed_response["ResultSet"]
    $usergroupID = usergroup_details[0]["id"]
  }

  user = group_and_user.drop(1)
  user.each do |user|
  # get userID
  api_to_get_userID = "https://" + as + "/API/system/users/search?username=" + user

  get_request('get_user','Get',api_to_get_userID) {|res|
    hashed_response_user = JSON.parse(res.body)
    user_details = hashed_response_user["Users"]
    $userID = user_details[0]["Id"]["Value"]
  }

  # add a uer to usergroup
  add_user_to_usergroup = "https://" + as + "/API/system/usergroups/" + $usergroupID.to_s + "/user/" + $userID.to_s + "/addusertogroup"
  post_request('addusertogroup', add_user_to_usergroup)

  end
end