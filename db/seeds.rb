# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
# case Rails.env
# when 'development'
# when 'test'
# when 'production'
now = Time.now

5.times { |index| 
	User.create! email: "testuser#{index+1}@test.com", password: "#{index+1}"*5, last_login: now + index.seconds 
}
feed_urls = [
	"http://feeds.bbci.co.uk/news/rss.xml",
	"http://feeds.reuters.com/reuters/technologyNews",
	"http://www.telegraph.co.uk/news/politics/rss"
]
feeds = Array.new

feed_urls.each do |feed_url|
	feed = Feed.parse_feed feed_url
	feed.updated = nil
	feed.save!
	feeds.push feed
end

# feeds = Feed.create! [
#   { title: "SPORT 24", link: "http://www.sport24.gr/latest/", description: "News feed", updated: now, type: nil, icon: "http://www.sport24.gr/skins/bugs-fixed/img/logo.png"},
#   { title: "BBC News - Home", link: "http://feeds.bbci.co.uk/news/rss.xml", description: "The latest stories from the Home section of the BBC News web site.", updated: now, type: nil, icon: "http://news.bbcimg.co.uk/nol/shared/img/bbc_news_120x60.gif"},
#   { title: "Reuters: Technology News", link: "http://feeds.reuters.com/reuters/technologyNews", description: "Reuters.com is your source for breaking news, business, financial and investing news.", updated: now, type: nil, icon: "http://www.reuters.com/resources_v2/images/reuters125.png"},
# ]

User.all.each do |user|
	user.subscriptions << feeds.sample(2)	
end

# feeds.each do |feed|
# 	5.times do |index|
# 		entry = feed.entries.create! title: "Test title#{index+1}", pub_date: now + index.seconds
# 		entry.subscribers.each { |subscriber| entry.reads.create! user: subscriber }
# 	end
# end

# User.all.each do |user|
# 	user.reads.first.update! read: true
# 	user.reads.last.update! read: true	
# end