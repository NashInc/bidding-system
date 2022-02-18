require 'AfricasTalking'

username = ENV["username"] # use 'sandbox' for development in the test environment
api_key	= ENV["api_key"] # use your sandbox app API key for development in the test environment
AT = AfricasTalking::Initialize.new(username, api_key)

# production_username = "nashafrica"
# production_api_key = "65d4dd5840bd398011bfc3a7d44cc839fd3b421db64d8d3a40c439eb7eb7817e"
# sandbox_api_key = "bab24092605e789894bd50f1430a63973e9156863d3f4b35e7a9a4b4e1c28073"
