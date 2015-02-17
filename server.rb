require 'rubygems'
require 'bundler'
Bundler.require(:default)
Dotenv.load

get '/hi' do
  "Hello World!"
end

get '/image_me/:search' do
  get_image_url(params[:search])
end

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
