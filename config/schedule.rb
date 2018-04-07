# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
set :output, "log/cron_log.log"
#
every 5.minutes do
  rake "telebot:parse"
  puts "telebot:parse is done"
end

every 11.minutes do
  rake "telebot:send"
  puts "telebot:send is done"
end

every 21.minutes do
  rake "telebot:clean"
  puts "telebot:clean is done"
end

# Learn more: http://github.com/javan/whenever
