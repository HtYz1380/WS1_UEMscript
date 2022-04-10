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
  
    # which group to add a user to
    group1 = group_and_user[0]
  
    if group1 != nil
    # get usergroupID
    api_to_get_usergroupID1 = "https://" + as + "/API/system/usergroups/search?groupname=" + group1
  
    get_request('get_usergroup1','Get',api_to_get_usergroupID1) {|res|
      hashed_response1 = JSON.parse(res.body)
      usergroup1_details = hashed_response1["ResultSet"]
      $usergroupID1 = usergroup1_details[0]["id"]
    }
    end
  
    # which group to delete a user from
    group2 = group_and_user[1]
    if group2 != nil
    # get usergroupID
    api_to_get_usergroupID2 = "https://" + as + "/API/system/usergroups/search?groupname=" + group2
  
    get_request('get_usergroup2','Get',api_to_get_usergroupID2) {|res|
      hashed_response2 = JSON.parse(res.body)
      usergroup2_details = hashed_response2["ResultSet"]
      $usergroupID2 = usergroup2_details[0]["id"]
    }
    end
  
    user = group_and_user.drop(2)
    user.each do |user|
  
    # get userID
    api_to_get_userID = "https://" + as + "/API/system/users/search?username=" + user
  
    get_request('get_user','Get',api_to_get_userID) {|res|
      hashed_response_user = JSON.parse(res.body)
      user_details = hashed_response_user["Users"]
      $userID = user_details[0]["Id"]["Value"]
    }
  
      if group2 == nil && group1 != nil
      # add a uer to usergroup
      p "Add " + user + " to " + group1 + "."
      add_user_to_usergroup = "https://" + as + "/API/system/usergroups/" + $usergroupID1.to_s + "/user/" + $userID.to_s + "/addusertogroup"
      post_request('addusertogroup', add_user_to_usergroup)
  
      elsif group2 != nil && group1 == nil
      # delete a uer from usergroup
      p "Delete " + user + " from " + group2 + "."
      delete_user_from_usergroup = "https://" + as + "/API/system/usergroups/" + $usergroupID2.to_s + "/user/" + $userID.to_s + "/removeuserfromgroup"
      post_request('deleteuserfromgroup', delete_user_from_usergroup)
  
      elsif group2 != nil && group1 != nil
      # move a user from group to group
      p "Move " + user + " from " + group2 + " to " + group1 + "."
      add_user_to_usergroup = "https://" + as + "/API/system/usergroups/" + $usergroupID1.to_s + "/user/" + $userID.to_s + "/addusertogroup"
      post_request('addusertogroup', add_user_to_usergroup)
  
      delete_user_from_usergroup = "https://" + as + "/API/system/usergroups/" + $usergroupID2.to_s + "/user/" + $userID.to_s + "/removeuserfromgroup"
      post_request('deleteuserfromgroup', delete_user_from_usergroup)
      end
    end
  end