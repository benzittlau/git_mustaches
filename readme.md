# Git Mustache
This is a demo project to walk through using the postman and ngrok tools to building against, and for API's

# Introduction

In building this quick project we're going to go through a few steps

* Build an API Endpoint in Sinatra
* Build against the google images API, first in postman, then in sinatra
* Build against the github API, first in postman, then in sinatra
* Build against the github webhook API using ngrok
* Build against the mustachify.me API, first in postman, then in sinatra

# Building an API endpoint in sinatra
This is pretty quick and easy

``` ruby
get '/hi' do
  "Hello World!"
end
```

Now let's test it with postman
