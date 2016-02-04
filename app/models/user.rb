class User < ActiveRecord::Base

	has_secure_password

	has_and_belongs_to_many :subscriptions, class_name: "Feed"
	has_many :entries, through: :subscriptions, source: :entries
	has_many :reads

	validates :email, presence: true, uniqueness:true
	
	def unsubscribe(feed)
		status = false
		begin
			ActiveRecord::Base.transaction do
				Object.const_get("Read").destroy_all(user_id: self.id, entry_id: feed.entry_ids)
				self.subscriptions.delete feed
			end
			status = true
		rescue ActiveRecord::RecordInvalid => e
			status = false
			raise ActiveRecord::Rollback
		end
		status
	end
end
