######################################################################################
# Requiring some built-in libraries of ruby 2.5.1p57 (2018-03-29 revision 63029).
# This is one of common parts for all of my scripts.
# It's not recommended to change this part unless you do require other libraries.
######################################################################################

require 'net/http'
require 'uri'
require 'json'

######################################################################################
# Set variables.
# Please set & add variables 
######################################################################################

# The number of your UEM host. useally 504 or 1109 in APAC shared. 
# This is a mandatory variable.
cn = ''

# The number of your tenant on the UEM host. 
# Usually this number is the last four number of the URL that cloud be seen 
# When you gonna Groups & Settings > Groups > Organization Groups > Detail on your UEM console.
# This is an optional variable (but a mandatory one in many cases, so it's recommended to set a value).
gid = ''

# Please Enter your Administrative account name and passwd.
# This is a mandatory variable.
$accountname = ''
$passwd = ''

# This key should be copied from Groups & Settings > All Settings > System > Advanced > API > REST API.
# By default, REST API settings are inherited from Global organization group(the group could only be seen from VMware Support team),
# Please change the setting from inherit to override when you copy the key value from the page.
# This is a mandatory variable.
$rest_key = ''

######################################################################################
# Define a method to perform Delete or Get
# This is one of common parts for all of my scripts
# It's not recommended to change this part unless you do require other methods.
######################################################################################

def uem_req(name ,meth, api_uri)

  uri = URI.parse(api_uri)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

# Create a HTTP request instance(Get or Delete).
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

# Yield HTTP response as the values will be closed in the method by default.
  yield(res)

end

######################################################################################
# Perform a Get and parse the response to get a specified organization group
# Please change as you like.
######################################################################################

# Please enter the url of the API 
api = 'https://as' + cn +'.awmdm.com/API/system/users/search?locationgroupId=' + gid

# create a get request and parse 
uem_req('get_user','Get',api) { |res| 

  hash = JSON.parse(res.body)
  ary = hash.fetch("Users")

# If you would like to inspect keys of an user account, please enable below puts line.
#   puts ary[0].keys
   
  $fetched_users = Hash.new()

    ary.each do |i|
      if i.fetch("Status") == false then
#        $fetched_users.replace(i)
        puts i
      end
    end

}

puts $fetched_users

