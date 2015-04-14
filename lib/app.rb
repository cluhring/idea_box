require 'idea_box'
require 'pry'
require 'redis'
require 'json'

$redis = Redis.new

class IdeaBoxApp < Sinatra::Base
	set :method_override, true
	set :root, 'lib/app'

	configure :development do
		register Sinatra::Reloader
	end


	get '/' do
		erb :index, locals: {ideas: IdeaStore.all.sort, idea: Idea.new(params)}
	end

	get '/playground' do
		@adjective = ["nice", "alright", "decnet"].shuffle.first
		erb :playground
	end

	helpers do
		def shout(words)
			words.upcase
		end
	end

	# register Sinatra::Partial
	# set :partial_template_engine, :erb

	# get '/no-layout' do
	# 	erb :index, :locals {ideas: IdeaStore.all.sort, idea: Idea.new(params)}, layout: false
	# end

	post '/' do
		$redis.publish :community, params[:idea].to_json
		$redis.subscribe(:community) do |on|
			on.message do |channel, msg|
		message = JSON.parse(msg)

		data = {
			username: message['title'],
			icon_url: "http://robohash.org/#{message['title']}.png",
			text: message['description']
		}

		conn.post do |req|
			req.url "/services/#{ENV['SLACKER_WEBHOOK']}"
			req.headers['Content-Type'] = 'application/json'
			req.body = data.to_json
		end
	end
end
		# params.inspect
		# 1. Create an idea based on the form parameters
		idea = IdeaStore.create(params[:idea])

		# 2. Store it
		# idea.save
		# 3. Send us back to the index page to see all ideas
		redirect '/'
	end

	not_found do
		erb :error
	end

	delete '/:id' do |id|
  		# "DELETING an idea!"
  		IdeaStore.delete(id.to_i)
  		redirect '/'
	end

	get '/:id/edit' do |id|
		# "Edit that shit!"
		idea = IdeaStore.find(id.to_i)
		erb :edit, locals: {idea: idea}
	end

	put '/:id' do |id|
		# "Tweaking the IDEA!"
		IdeaStore.update(id.to_i, params[:idea])
		redirect '/'
	end

	post '/:id/like' do |id|
		idea = IdeaStore.find(id.to_i)
		idea.nice
		IdeaStore.update(id.to_i, idea.to_h)
		redirect '/'
		# "I like this idea!"
	end

	post '/:id/dislike' do |id|
		idea = IdeaStore.find(id.to_i)
		idea.naughty
		# binding.pry
		IdeaStore.update(id.to_i, idea.to_h)
		redirect '/'
	end

end

__END__
