$:.unshift File.expand_path("../../lib", __FILE__)
require 'bundler'
Bundler.require :default, :test
require 'sinatra/base'
require_relative '../lib/app.rb'
require 'minitest/autorun'
require 'rack/test'
require 'nokogiri'

class IdeaBoxAppTest < Minitest::Test
	include Rack::Test::Methods

	def app
		IdeaBoxApp.new
	end

	def test_Nokogiri_works
		get '/playground'
		html = Nokogiri::HTML(last_response.body)
		assert last_response.ok?
		assert_equal "IdeaBox", html.css('title').text
	end

	def test_file_not_found_works
  	post '/goodbye'
  	assert_equal 404, last_response.status
  	assert_equal "IdeaBox Error", html.css('title').text
  end

  def test_index_file_path_works
  	get '/'
  	assert last_response.ok?
   	assert_equal 200, last_response.status
 	end
end
