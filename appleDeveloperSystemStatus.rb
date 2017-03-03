require 'json'
require 'net/http'


PAGE_URL = "https://developer.apple.com/system-status/"

JS_URL = "https://www.apple.com/support/systemstatus/data/developer/system_status_en_US.js"
RESPONSE_PREFIX_TO_REMOVE = "jsonCallback("
RESPONSE_SUFFIX_TO_REMOVE = ");"


SERVICES_JSON_KEY = "services"
SERVICE_NAME_JSON_KEY = "serviceName"
EVENTS_JSON_KEY = "events"
EVENT_STATUS_JSON_KEY = "eventStatus"

EVENT_STATUS_RESOLVED_JSON_VALUE = "resolved"


def getServicesFromAppleDeveloperSystemStatus()
  jsonString = getJSONStringFromURL(JS_URL,
                                    RESPONSE_PREFIX_TO_REMOVE,
                                    RESPONSE_SUFFIX_TO_REMOVE)
  json = JSON.parse(jsonString)
  return json[SERVICES_JSON_KEY]
end

def getJSONStringFromURL(url, responsePrefixToRemove, responseSuffixToRemove)
  response = Net::HTTP.get_response(URI.parse(url))
  data = response.body
  dataString = "#{data}"
  startIndex = responsePrefixToRemove.length
  substringLength = dataString.length-responsePrefixToRemove.length-responseSuffixToRemove.length
  return dataString[startIndex, substringLength]
end

def getServiceName(service)
  return service[SERVICE_NAME_JSON_KEY]
end

def getUnsolvedEventsForService(service)
  events = service[EVENTS_JSON_KEY]
  return events.find_all{ |hash| hash[EVENT_STATUS_JSON_KEY] != EVENT_STATUS_RESOLVED_JSON_VALUE }
end

def isServiceStatusOk(service)
  serviceUnsolvedEvents = getUnsolvedEventsForService(service)
  return (serviceUnsolvedEvents.length == 0)
end

def getServiceStatusFlagString(serviceStatus)
  return (serviceStatus ? "✅" : "🔥")
end

def getServiceStatusFormattedString(service)
  isServiceStatusOk = isServiceStatusOk(service)
  return "#{getServiceStatusFlagString(isServiceStatusOk)}  #{getServiceName(service)}"
end

def main()
  services = getServicesFromAppleDeveloperSystemStatus()

  puts "Apple Developer System Status"
  puts "#{PAGE_URL}"
  for i in 0..services.length-1
    puts getServiceStatusFormattedString(services[i])
  end
end


# *****************

main()
