# Requires java and the jar files needed to make web service requests
require 'java'

# The jar files are located in the jars directory to avoid cluttering lib
$:.unshift File.dirname(__FILE__) + '/../jars'

# Require Spring Web Service dependencies
# JRuby lets you require a jar file to make the classes available.
require 'commons-logging-1.1.1.jar'
require 'spring-beans-3.0.5.RELEASE.jar'
require 'spring-context-3.0.5.RELEASE.jar'
require 'spring-core-3.0.5.RELEASE.jar'
require 'spring-oxm-3.0.5.RELEASE.jar'
require 'spring-xml-2.0.2.RELEASE.jar'
require 'spring-ws-core-2.0.2.RELEASE.jar'
require 'spring-ws-support-2.0.2.RELEASE.jar'

# java_import makes a Java class available by its class name
# We'll import a few classes that we'll use to make web service requests
java_import("org.springframework.oxm.jaxb.Jaxb2Marshaller")
java_import("org.springframework.ws.soap.saaj.SaajSoapMessageFactory")
java_import("org.springframework.ws.client.core.WebServiceTemplate")

# Require the generated and compiled JAXB code to talk to the ECHO API..
# This is built from the command line
# Run "rake" in the magic_web_service directory
require 'echo_ws.jar'

# Make generated JAXB classes available within a Ws module.
# This is another way of making java classes available.
# Define a module and call include_package to make the classes in the Java package
# scoped within the module.
module Ws
  include_package "authentication"
end
