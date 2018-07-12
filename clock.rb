require 'clockwork'
include Clockwork
require './config/boot'
require './config/environment'

handler do |job, time|
  puts "Running #{job}, at #{time}"
end

every(15.seconds, 'do_something') do

end