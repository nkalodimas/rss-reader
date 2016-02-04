class Read < ActiveRecord::Base
  belongs_to :user
  belongs_to :entry

  def self.mark_as_read(user_id, entry_id, read)
    self.find_by_user_id_and_entry_id!(user_id, entry_id).update!(read: read )
  end
end
