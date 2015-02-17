# Git Mustache
This is a demo project to walk through using the postman and ngrok tools to building against, and for API's

# Introduction

In building this quick project we're going to go through a few steps

* Build an API Endpoint in Sinatra
* Build against the google images API, first in postman, then in sinatra
* Build against the github API, first in postman, then in sinatra
* Build against the github webhook API using ngrok
* Build against the mustachify.me API, first in postman, then in sinatra

## Building an API endpoint in sinatra
This is pretty quick and easy
http://www.sinatrarb.com/

``` ruby
get '/hi' do
  "Hello World!"
end
```

Now let's test it with postman

## Building against the google images API in postman
This is also pretty easy
https://developers.google.com/image-search/v1/jsondevguide

We can test in postman doing a GET to:
https://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=fuzzy%20monkey

We can try adding the imgtype=face to the params we send to the API

We can try restricing the file type to JPEG


## Building against the google images API in sinatra
Now let's make an endpoint that takes a body that we use for image search

This is what we end up with:

``` ruby
get '/image_me/:search' do
  get_image_url(params[:search])
end

def get_image_url(query)
  options = {
    :query => {
      :v => 1.0,
      :imgtype => 'face',
      :as_filetype => 'jpeg',
      :rsz => 1,
      :q => query
    }
  }
  response = HTTParty.get('https://ajax.googleapis.com/ajax/services/search/images', options)

  JSON.parse(response.body)["responseData"]["results"][0]["url"]
end
```


## Building against the github API using postman
First we'll need an Oauth token; I've already gone ahead and done this
https://help.github.com/articles/creating-an-access-token-for-command-line-use/

We'll need to use that in an authorization header:

https://developer.github.com/v3/#authentication

Authorization: token OAUTH_TOKEN

Let's try it using postman, against https://api.github.com/user

Now let's try *doing* something using postman
https://developer.github.com/v3/issues/comments/

POST /repos/:owner/:repo/issues/:number/comments

In this case:
POST /repos/benzittlau/git_mustaches/issues/1/comments

``` json
{
  "body": "Me too"
}
```

Let's see if it worked.  Cool!

## Building against the github API using sinatra
Let's build an API endpoint to comment on an issue

Weird gotcha for github's API is we need to have a user agent header:
http://developer.github.com/v3/#user-agent-require

The body can be a hash with to_json called on it

When successful we should get a 201 response.  Here's an example of working code:

``` ruby
get '/comment_me/:phrase' do
  status comment_on_issue(params[:search])
end

def comment_on_issue(phrase)
  options = {
    :body => { :body => 'From Sinatra' }.to_json,
    :headers => {
      "Authorization" => "token #{ENV['GITHUB_OAUTH2_TOKEN']}",
      "User-Agent" => 'benzittlau'
    }
  }

  response = HTTParty.post('https://api.github.com/repos/benzittlau/git_mustaches/issues/1/comments', options)

  response.code
end
```

At this point we have our API hitting another API, that's pretty cool!

