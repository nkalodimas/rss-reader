class Feed < ActiveRecord::Base
	has_and_belongs_to_many :subscribers, class_name: "User"
	has_many :entries, dependent: :destroy

	validates :link, uniqueness: true

	scope :ordered_by_title, -> { order title: :asc }
	scope :popular, -> { 
		select("feeds.*, COUNT(subscriptions.user_id) as subscribers_count").
        joins("LEFT JOIN feeds_users AS subscriptions ON subscriptions.feed_id = feeds.id").
        group("feeds.id").
        order("subscribers_count DESC")
    }
	# scope :popular, -> { 
	# 	includes(:subscribers).
	# 	group('feeds_users.feed_id').
	# 	references(:subscribers).
	# 	order("count(feeds_users.feed_id) DESC")
	# }
	def self.parse_feed(url)
		feed = nil
		begin
			parsed_feed = Feedjira::Feed.fetch_and_parse url
			title = parsed_feed.title
			link = parsed_feed.feed_url
			description = parsed_feed.description
			updated = parsed_feed.last_modified.to_datetime
			#type
			#icon
			feed = Feed.new title: title, link:link, description: description, updated: updated
		rescue StandardError => err
			puts "Error raised in Feed.parse_feed: #{err.inspect}"
			feed = nil
		end
		feed
	end

	def parse_entries
		begin
			entries = Feedjira::Feed.fetch_and_parse(self.link).entries
		rescue StandardError => err
			entries = nil
			return false
		end
		parsed_entries =  Array.new
		entries.each do |entry|
			parsed_entry = Entry.parse_entry entry
			return false unless parsed_entry
			parsed_entries.push parsed_entry
		end
		parsed_entries
	end

	def self.add_new_feed_and_subscribe(feed_url, subscriber)
		status = false
		begin
			ActiveRecord::Base.transaction do
				feed = self.parse_feed feed_url
				raise ActiveRecord::RecordInvalid unless feed
				feed.save
				parsed_entries = feed.parse_entries
				feed.entries << parsed_entries if parsed_entries
				feed.subscribers << subscriber
				if feed.subscribers.exists? subscriber.id
					feed.entries.limit(25).each { |e| e.reads.create! user: subscriber }
					status = true
				end
			end
		rescue ActiveRecord::RecordInvalid => e
			status = false
			raise ActiveRecord::Rollback
		end
		status
	end

	def add_subscriber(subscriber)
		status = false
		begin
			ActiveRecord::Base.transaction do
				self.subscribers << subscriber
				if self.subscribers.exists? subscriber.id
					self.entries.limit(10).each { |e| e.reads.create! user: subscriber }
					status = true
				end
			end
		rescue ActiveRecord::RecordInvalid
			status = false
			raise ActiveRecord::Rollback
		end
		status
	end

	def self.update_feeds
		feeds = Feed.all.to_a
		feeds.each do |feed|
			puts "Fetching #{feed.title} ..."
			begin
				fetched_feed = Feedjira::Feed.fetch_and_parse feed.link
				next if feed.updated && fetched_feed.last_modified.to_datetime <= feed.updated
				new_entries =  Array.new
				last_entry = feed.entries.first
				err = nil
				fetched_feed.entries.each do |entry|
					break if last_entry && entry.published.to_datetime <= last_entry.pub_date
					parsed_entry = Entry.parse_entry entry
					err = true and break unless parsed_entry
					new_entries.push parsed_entry
				end
				next if err
				ActiveRecord::Base.transaction do
					feed.entries << new_entries
					new_entries.each do |entry|
						feed.subscribers.each { |s| entry.reads.create! user: s }
					end
					feed.update(updated: fetched_feed.last_modified.to_datetime)
				end
				puts "Added #{new_entries.size} new entries"
			rescue ActiveRecord::RecordInvalid => err
				puts "Error raised in Feed.update_feeds: #{err.inspect}"
				raise ActiveRecord::Rollback
				next
			rescue StandardError => err
				puts "Error raised in Feed.update_feeds: #{err.inspect}"
				next
			end
		end
	end
end