class Entry < ActiveRecord::Base
	attr_accessor :read

  belongs_to :feed
  has_many :subscribers, through: :feed, source: :subscribers, class_name: "User"
  has_many :reads, dependent: :destroy

  validates :summary, length: { maximum: 255 }
  # TODO: validate unique feed_id and entry_id
  default_scope { order pub_date: :desc }
  scope :for_user, ->(user_id, limit) { includes(:feed, :reads).where(reads: {user: user_id}).limit(limit) } do |variable|
		def set_read_attribute
			each do |entry|
				if entry.reads.size == 1
					entry.read = entry.reads.first.read
				else
					entry.read = true # old entries from existing feeds are marked as read for the user
				end
			end
		end
  end

	def self.parse_entry(entry)
		new_entry = nil
		begin
			new_entry = Entry.new title: entry.title, link: entry.url, summary: entry.summary[0..254], pub_date: entry.published.to_datetime, entryId: entry.entry_id
		rescue StandardError => err
			puts "Error raised in Feed.parse_feed: #{err.inspect}"
			new_entry = nil
		end
		new_entry
	end

	def self.delete_entries(older_than)
		begin
			ActiveRecord::Base.transaction do
				deletedEntries = Entry.where(["pub_date < ?", older_than.hours.ago]).destroy_all
				puts "#{deletedEntries.size} entries were deleted."
			end
		rescue ActiveRecord::RecordInvalid
			raise ActiveRecord::Rollback
		end
	end

end