# Git Mustache
This is a demo project to walk through using the postman and ngrok tools to building against, and for API's

# Introduction

In building this quick project we're going to go through a few steps

* Build an API Endpoint in Sinatra
* Build against the google images API, first in postman, then in sinatra
* Build against the github API, first in postman, then in sinatra
* Build against the github webhook API using ngrok
* Build against the mustachify.me API, first in postman, then in sinatra

# Disclaimer
The purpose of this talk is *not* showing how to build a good API, and many shortcuts are
taken in the sinatra API that is built to try and move quickly through integrating
the other API's, and highlighting how to use Postman and NGROK to facilitate.

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

## Building against the github webhook API using ngrok
Now we want to try and wire up to some github callbacks

Next we'll need to get ngrok setup
http://zittlau.ca/develop-against-external-webhooks-locally-using-ngrok/

After install we'll run it:
/Applications/ngrok 4567

We can test it using postman
http://47a49730.ngrok.com/image_me/the world

And take a look using the web interface
http://localhost:4040/http/in

Here we can take a look at, and resubmit, the request

Now let's setup a basic sinatra endpoint and give it to github in our repo settings for issue comments

Now if we do a test comment we'll see it show up in ngrok

Now that we have an example in ngrok we can test our code without having to use github

## Connecting it all together

Let's connect all the pieces, so that if the comment is of the form "image me <string>" we'll inject an image
with the url that our image_url method returns into the github issue

First let's capture a request by creating a comment on the issue in github.  This will let ngrok capture it and
give us a base to work with

Hint: The markdown for embedding an image is
``` gfm
![Image of Yaktocat](https://octodex.github.com/images/yaktocat.png)
```

``` ruby
post '/github_webhook' do
  json = JSON.parse(request.body.read)
  comment = json["comment"]["body"]

  if matches = /^image me (.*)$/i.match(comment)
    phrase = matches[1]
    image_url = get_image_url(phrase)

    image_markdown = "![Image of #{phrase}](#{image_url})"
    comment_on_issue(image_markdown)

    image_markdown
  end
end
```
