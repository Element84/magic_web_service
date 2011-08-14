require 'magic_web_service'

# Defines methods that can be used to return the different services defined on a web service API
module Services
  # An array of the different services that will be defined on an including class.
  SERVICES = [:authentication]

  # A hash of the service name to MagicWebService instances
  SERVICE_HASH = SERVICES.inject({}) do |hash, service|
    hash[service] = MagicWebService.new(service)
    hash
  end

  SERVICES.each do |service|
    # Define the accessor method for the MagicWebService
    define_method("#{service}_service") do
      SERVICE_HASH[service]
    end
  end

end