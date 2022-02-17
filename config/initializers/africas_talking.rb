require 'AfricasTalking'

username = 'nashafrica' # use 'sandbox' for development in the test environment
api_key	= '897f616c3583c5e1438b59b6911a61fdcf35e1f8e337f52b8c3f26a8705a097f' # use your sandbox app API key for development in the test environment
AT = AfricasTalking::Initialize.new(username, api_key)

# production_username = "nashafrica"
# production_api_key = "11b1bcbc6576ee6379efccb7b0a06d2060395c0734e7d2155a5b2359533e30d2"
# sandbox_api_key = "bab24092605e789894bd50f1430a63973e9156863d3f4b35e7a9a4b4e1c28073"