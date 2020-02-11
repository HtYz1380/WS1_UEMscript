require 'net/http'
require 'uri'
require 'json'

##########################################
# Set variables
##########################################

cn = ''
gid = ''
$accountname = ''
$passwd = ''
$rest_key = ''
srch_og = ''

##########################################
# Define a method to perform Delete or Get 
##########################################

def uem_req(name ,meth, api_uri)

  uri = URI.parse(api_uri)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  if meth == 'Get' 
    name = Net::HTTP::Get.new(uri.request_uri)
  elsif meth == 'Delete'
    name = Net::HTTP::Delete.new(uri.request_uri)
  else
    puts 'pls enter Get or Delete'
  end

  name.basic_auth($accountname, $passwd ) 
  name.add_field('aw-tenant-code', $rest_key )
  name.add_field('Accept','application/json' )

  res = http.request(name)
  puts res.code, res.msg

  yield(res)

end

##########################################
# Perform a Get and parse the response to get a specified organization group
##########################################

api = 'https://as' + cn + '.awmdm.com/API/system/groups/' + gid + '/children'

uem_req('get_cogs','Get',api) { |res| 

  ary = JSON.parse(res.body)
  $searched_og = Hash.new()

   ary.each do |i|
     if i.value?(srch_og) then
       $searched_og.replace(i)
     end
   end

}

puts $searched_og

