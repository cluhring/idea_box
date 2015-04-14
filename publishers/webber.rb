require 'sinatra'
require './lib/redis-config'

get '/' do
  erb :index
end

post '/' do
  $redis.publish :community, params.to_json
  @message = 'Your post has been published.'
  erb :index
end

__END__
