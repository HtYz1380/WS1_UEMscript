require 'net/http'
require 'uri'

cn = ''
gid = ''
accountname = ''
passwd = ''
rest_key = ''

uri = URI.parse('https://as' + cn +'.awmdm.com/API/system/users/search?locationgroupId=' + gid)
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true

req = Net::HTTP::Get.new(uri.request_uri)

req.basic_auth(accountname, passwd ) 
req.add_field('aw-tenant-code', rest_key )
req.add_field('Accept','application/json' )

res = http.request(req)

puts res.code, res.msg
puts res.body
