require 'java_dependencies'
require 'inflector_methods'
require 'java_property_setter'

# The MagicWebService responds to operation calls using method_missing.  It converts the method
# name called and arguments into the correct request object and invokes the SOAP operation.
class MagicWebService

  # Initializes the Spring objects need to make web service requests.
  def initialize(service_name)
    marshaller = Jaxb2Marshaller.new
    marshaller.context_paths = "authentication"

    message_factory = SaajSoapMessageFactory.new
    # We call after_properties_set because SaajSoapMessageFactory is normally created in a spring 
    # context file.  Spring would call this after initializing the object.
    message_factory.after_properties_set

    @service_template = WebServiceTemplate.new(message_factory)
    @service_template.marshaller = marshaller
    @service_template.unmarshaller = marshaller
    @service_template.default_uri = "https://api.echo.nasa.gov/echo-v10/#{service_name.to_s.camelize}ServicePortImpl"
  end

  # Handles all web service operation requests.  Converts the method name into a JAXB request
  # object.  Sets the arguments on the JAXB request object and then invokes the web service
  # operation.
  def method_missing(name, *args)
    jaxb_request_class = Ws.const_get(name.to_s.camelize)
    request = jaxb_request_class.new
    set_properties(request, args)
    response = @service_template.marshal_send_and_receive(request)
    if response.respond_to? :result
      response.result
    end
  end

  private

  # Sets the properties on the JAXB java object.
  # Properties is an array that matches the element order defined in the JAXB object
  def set_properties(java_obj, properties)
    JavaPropertySetter.new(java_obj).set_properties_from_array(properties)
  end

end