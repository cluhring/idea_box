require 'redis'
require 'json'

$redis = ENV['IDEA_REDIS'] ? Redis.new(url: ENV['IDEA_REDIS']) : Redis.new
