require 'java'

#spring dependencies
require 'spring-beans-3.0.5.RELEASE.jar'
require 'spring-context-3.0.5.RELEASE.jar'
require 'spring-oxm-3.0.5.RELEASE.jar'
require 'spring-core-3.0.5.RELEASE.jar'
require 'commons-logging-1.1.1.jar'
require 'spring-ws-core-2.0.2.RELEASE.jar'
require 'spring-ws-support-2.0.2.RELEASE.jar'
require 'spring-xml-2.0.2.RELEASE.jar'

# This is built from the command line
# Run "ant" in the magic_webservice directory
require 'echo_ws.jar'

java_import("org.springframework.oxm.jaxb.Jaxb2Marshaller")
java_import("org.springframework.ws.soap.saaj.SaajSoapMessageFactory")
java_import("org.springframework.ws.client.core.WebServiceTemplate")
