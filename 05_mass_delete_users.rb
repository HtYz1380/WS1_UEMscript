require 'net/http'
require 'uri'
require 'json'

##########################################
# Set variables
##########################################

cn = ''
gid = ''
accountname = ''
passwd = ''
rest_key = ''
srch_og = ''

##########################################
# search the organization group
##########################################

uri = URI.parse('https://as' + cn +'.awmdm.com/API/system/groups/' + gid + '/children')
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true

req = Net::HTTP::Get.new(uri.request_uri)

req.basic_auth(accountname, passwd ) 
req.add_field('aw-tenant-code', rest_key )
req.add_field('Accept','application/json' )

res = http.request(req)

puts res.code, res.msg
ary = JSON.parse(res.body)
searched_og = Hash.new()

ary.each do |i|
  if i.value?(srch_og) then
    searched_og.replace(i)
  end
end

##########################################
# yank mass user accounts..
##########################################

user_yank_gid = searched_og.fetch("Id").fetch("Value")

uri_user_yank = URI.parse('https://as' + cn +'.awmdm.com/API/system/users/search?locationgroupId=' + user_yank_gid.to_s)
http_user_yank = Net::HTTP.new(uri_user_yank.host, uri_user_yank.port)
http_user_yank.use_ssl = true

req_user_yank = Net::HTTP::Get.new(uri_user_yank.request_uri)

req_user_yank.basic_auth(accountname, passwd ) 
req_user_yank.add_field('aw-tenant-code', rest_key )
req_user_yank.add_field('Accept','application/json' )

res_user_yank = http_user_yank.request(req_user_yank)

users = JSON.parse(res_user_yank.body)
users_ary = users.fetch("Users")

##########################################
# Delete yanked user accounts...
##########################################

deluers = Array.new()

users_ary.each do |u|
  user_id = u.fetch("Id").fetch("Value").class

  uri_udel = URI.parse('https://as' + cn +'.awmdm.com/API/system/users/' + user_id.to_s '/delete')
  http_udel = Net::HTTP.new(uri_udel.host, uri_udel.port)
  http_udel.use_ssl = true

  req_udel = Net::HTTP::Get.new(uri_udel.request_uri)

  req_udel.basic_auth(accountname, passwd ) 
  req_udel.add_field('aw-tenant-code', rest_key )
  req_udel.add_field('Accept','application/json' )

  res_udel = http_udel.request(req_udel)
  puts res_udel.code, res_udel.msg, res_udel.body
  
end

# currently this script could not find users who has no device enrolled.
# needs to be enhanced

