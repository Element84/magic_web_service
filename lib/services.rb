require 'magic_web_service'

# Defines methods that can be used to return the different services defined on a web service API
module Services
  # An arry of the different services that will be defined on an including class.
  SERVICES = [:authentication]

  SERVICE_HASH = SERVICES.inject({}) do |hash, service|
    hash[service] = MagicWebService.new(service)
    hash
  end

  # The included hook method invoked when Services module is included.
  # base is including class.
  def self.included(base)
    SERVICES.each do |service|
      #Define the accessor method for the MagicWebService
      base.send(:define_method, "#{service}_service") do
        SERVICE_HASH[service]
      end
    end
  end


end