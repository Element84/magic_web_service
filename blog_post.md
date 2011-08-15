JRuby and Metaprogramming with Java
===================================

JRubyConf 2011 was two weeks ago on August 3rd and 4th where I gave a talk entitled "Building the Magic Web Service".  My presentation covered how the NASA ECHO developers built a Ruby gem using existing Java libraries to make SOAP web service requests.  One of the topics my talk covered was the use of metaprogramming in JRuby with Java objects.  I'm going to detail more of those metaprogramming techniques in this blog.  Before diving in you should check out the magic_web_service project on Github at <https://github.com/Element84/magic_web_service>.  It's not the actual code used on our project but it demonstrates the metaprogramming techniques detailed in this article.  

The SOAP API
------------
SOAP is an XML protocol for making programmatic requests over the Internet.  The magic_web_service project demonstrates communicating with a SOAP API on the [NASA ECHO system](http://www.echo.nasa.gov), an Earth Science metadata repository provided by NASA.  The magic_web_service project demonstrates logging in as a guest and logging out.

Spring Web Services and JAXB are Java libraries that support making SOAP web service requests.  [JAXB](http://jaxb.java.net/) is an XML marshaling library built into Java that comes with a Java code generator called XJC.  XJC can be fed an XML schema that describes messages on a SOAP API and it will output Java objects that can generate and parse the XML to communicate with the API.  It generates a Java class for each of the types defined in the XML Schema.  [Spring Web Services](http://static.springsource.org/spring-ws/sites/2.0/) handles the HTTP communication with the API and uses JAXB to marshal the XML.

Accessing Java Code in Ruby
---------------------------
Before you begin creating and manipulating Java objects in Ruby you have to get access to the compiled Java class files.  JRuby will make them available if the class or jar files are in the classpath or by requiring a jar file the same way you would require a Ruby file. 

magic_web_service/lib/java_dependencies.rb

    # Require the generated and compiled JAXB code to talk to the ECHO API
    require 'echo_ws.jar'

After you've required the jar files you can access the Java classes in JRuby.  There are a few different ways to do this.  One way that prevents you from having to spell out the full java package every time is to include it in a module.  The classes will then be scoped within a module for easy access.

magic_web_service/lib/java_dependencies.rb

    # Make generated JAXB classes available within a Ws module.
    module Ws
      include_package "authentication"
    end

Scripting Java from Ruby
------------------------
The [JRuby Wiki](https://github.com/jruby/jruby/wiki) shows many different ways to access Java objects using Ruby.  The demo_direct_scripting.rb file in the magic_web_service project demonstrates logging in and logging out using Spring Web Services and JRuby.

demo_direct_scripting.rb

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
    service_template.default_uri = "https://testbed.echo.nasa.gov/echo-v10/AuthenticationServicePortImpl"

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

Applying Metaprogramming
------------------------
These are Java objects we've been manipulating but JRuby still allows us to treat them like regular Ruby objects.  That means a lot of the same rules apply.  We can add methods at runtime, use reflection to list methods, and apply other metaprogramming techniques.  The code above is much less verbose than the equivalent Java code but we can do even better in Ruby.  The first step towards shortening the code is to come up with a goal.  We'll define the API that we'd like to use to make web service requests.  

demo_magic_web_service.rb excerpt

    class DemoMagicWebService
      include Services

      def run
        # Login as a guest
        # We need to pass client information to the api.  Any object will work through duck typing.
        client_info = OpenStruct.new
        client_info.client_id = "magic web service"
        client_info.user_ip_address = "127.0.0.1"

        token = authentication_service.login("guest", "mypassword", client_info)
        puts "Logged in with token #{token}"

        authentication_service.logout(token)
        puts "Logged out"
      end
    end

The above code shows the API that'd we like.  We want a module, `Services`, that when it's included makes different service methods available, such as `authentication_service`.  The `authentication_service` method returns an instance of the `MagicWebService` class that will dynamically handle the calls to web service operations.

The `Services` module uses `define_method` to dynamically add the methods that the module will make available.  `define_method` takes the name of the method to add and a block for the method body.  The ECHO API has 16 different services available.  If we were only going to define one or two service methods we probably wouldn't go to the trouble of using metaprogramming here.

services.rb

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

The `MagicWebService` class is where the real magic happens.  It performs its feats of dynamic strength by using `method_missing`.  `method_missing` is a method on Ruby objects that's called when a method is invoked that isn't defined.  It normally raises a `NoMethodError`.    `MagicWebService` overrides it to dynamically handle any different web service invocation. Notice that `method_missing` uses `const_get` on the `Ws` module to find the JAXB request class.  Recall from earlier that the `Ws` module included all the JAXB generated Java classes.  `const_get` looks up a constant by name and returns it.  

magic_web_service.rb

    class MagicWebService
      #  …

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

The `JavaPropertySetter` is responsible for setting properties on the generated Java objects.  The `MagicWebService` `method_missing` will receive the arguments to the web service operation in the order defined in the XML Schema element.  The `JavaPropertySetter` needs to set these arguments in the correct fields on the request object.  It's able to do this by using reflection on the generated JAXB object.

The generated JAXB objects contain Java annotations that tell JAXB how to map the object to XML.  The `@XmlType` annotation field `propOrder` lists the elements of the `Login` message in order.

Login.java

    @XmlAccessorType(XmlAccessType.FIELD)
    @XmlType(name = "", propOrder = {
        "username",
        "password",
        "clientInfo",
        "actAsUserName",
        "behalfOfProvider"
    })
    @XmlRootElement(name = "Login", namespace = "http://echo.nasa.gov/echo/v10")
    public class Login {

        @XmlElement(namespace = "http://echo.nasa.gov/echo/v10", required = true)
        protected String username;
        @XmlElement(namespace = "http://echo.nasa.gov/echo/v10", required = true)
        protected String password;
        // ...

Java's reflection API allows us to retrieve the annotation metadata from a class.  This is possible in normal Java code.  Ruby makes the code more concise than the Java version which is normally a chore to write.  Here's how the `JavaPropertySetter` does that in JRuby.

java_property_setter.rb

    # Makes the JAXB Java annotation classes available.
    module JaxbAnnotation
      include_package "javax.xml.bind.annotation"
    end

    # Later in class
    java_obj_class = @java_object.class.java_class
    annotation = java_obj_class.annotation(JaxbAnnotation::XmlType.java_class)
    property_names = annotation.prop_order.map(&:to_s) 

After the `JavaPropertySetter` has the property names in order it needs to get the types of the properties.  Java is a statically typed language so it knows the types of all fields at runtime.  The `JavaPropertySetter` uses reflection to get the type of each property.

    property_names.each do |name|
      type = java_obj_class.java_method("get#{name.camelize}").return_type.to_s
      @property_names_to_types[name.underscore] = type
    end

The `JavaPropertySetter` sets all of the values on each of the reflected properties.  It converts the value into the appropriate type.  When a simple type like strings or integers are encountered no conversion is done as JRuby automatically handles this.  When a complex object is encountered the `JavaPropertySetter` creates a new instance of the target type and calls recursively into itself to handle setting properties on that type.

Conclusion
----------
JRuby provides great benefits to developers coming to it from Ruby or from traditional Java backgrounds.  Ruby developers can take advantage of the large collection of Java libraries and frameworks available.  Traditional Java developers should look to JRuby as a suitable replacement for the Java programming language without having to leave the existing frameworks, libraries, and deployment schemes they already have in place.  JRuby's ability to take full advantage of the Ruby language, including metaprogramming, makes this especially appealing. 


Resources
---------
* JRuby Wiki - <https://github.com/jruby/jruby/wiki>
* magic_web_service Github - <https://github.com/Element84/magic_web_service>
* NASA ECHO SOAP API  - <https://api.echo.nasa.gov/echo/ws/v10/index.html>
* Spring Web Services - <http://static.springsource.org/spring-ws/sites/2.0/>
* JAXB - <http://jaxb.java.net/>
