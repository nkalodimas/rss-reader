desc "This task is called by the Heroku scheduler add-on 
and retrieves all new entries from existing feeds"
task :update_feeds => :environment do
  puts "Updating feeds..."
  Feed.update_feeds
  puts "done."
end

desc "This task removes old entries from db"
task :remove_entries, [:hours_ago] => :environment do |t, args|
  puts "Removing old entries"
  Entry.delete_entries args[:hours_ago].to_i
  puts "done."	
end