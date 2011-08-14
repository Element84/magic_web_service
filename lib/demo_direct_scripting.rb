# This file shows how we would directly script the use of Spring Web Services and JAXB 
# in JRuby to talk to a web service.  

require 'java_dependencies'

# We'll make a web service call to the NASA ECHO SOAP API as an example.
# ECHO (http://www.echo.nasa.gov) is an earth science metadata repository that has a SOAP API.  It's
# SOAP API is documented here: https://api.echo.nasa.gov/echo/apis.html  We'll use the SOAP API
# to login as a guest.  
# Login documentation: https://api.echo.nasa.gov/echo/ws/v10/AuthenticationService.html#Login

# 0. Setup the Spring WS classes
marshaller = Jaxb2Marshaller.new
marshaller.context_paths = "authentication"

message_factory = SaajSoapMessageFactory.new
# We call after_properties_set because SaajSoapMessageFactory is normally created in a spring 
# context file.  Spring would call this after initializing the object.
message_factory.after_properties_set

service_template = WebServiceTemplate.new(message_factory)
service_template.marshaller = marshaller
service_template.unmarshaller = marshaller
service_template.default_uri = "https://api.echo.nasa.gov/echo-v10/AuthenticationServicePortImpl"


# 1. Create the JAXB request object
login_request = Ws::Login.new

# 2. Set the properties on the request object.  The properties are the arguments to the web service 
# request.
login_request.username = "guest"
login_request.password = "mypassword"

# one of the properties is a complex object called ClientInformation.
client_info = Ws::ClientInformation.new
client_info.client_id = "magic web service"
client_info.user_ip_address = "127.0.0.1"
login_request.client_info = client_info

# 3. Send the request
response = service_template.marshal_send_and_receive(login_request)
# response is an instance of Ws::LoginResponse
token = response.result
puts "Logged in with token #{response.result}"

# 4. Logout using the same approach as above
logout_request = Ws::Logout.new
logout_request.token = token
service_template.marshal_send_and_receive(logout_request)
puts "Logged out"

