# Demonstrates using the MagicWebService to make web service requests.
# See direct_scripting.rb for the equivalent without metaprogramming.

# Require and include services.rb to make web service methods available
require 'services'
require 'ostruct'

class DemoMagicWebService
  include Services

  def run
    # Login as a guest
    # We need to pass client information to the api.  Any object will work through duck typing.
    client_info = OpenStruct.new
    client_info.client_id = "magic web service"
    client_info.user_ip_address = "127.0.0.1"

    token = authentication_service.login("guest","mypassword",client_info)

    puts "Logged in with token #{token}"

    authentication_service.logout(token)
    puts "Logged out"
  end
end

DemoMagicWebService.new.run
