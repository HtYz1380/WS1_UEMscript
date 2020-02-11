require 'net/http'
require 'uri'
require 'json'

cn = ''
gid = ''
accountname = ''
passwd = ''
rest_key = ''
srch = ''

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
hash = Hash.new()

ary.each do |i|
  if i.value?(srch) then
    hash.replace(i)
  end
end

puts hash
