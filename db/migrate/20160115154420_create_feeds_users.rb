class CreateFeedsUsers < ActiveRecord::Migration
  def change
    create_table :feeds_users, id: false do |t|
      t.references :user, index: true, foreign_key: true
      t.references :feed, index: true, foreign_key: true
    end
  end
end
