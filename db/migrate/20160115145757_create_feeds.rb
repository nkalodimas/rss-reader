class CreateFeeds < ActiveRecord::Migration
  def change
    create_table :feeds do |t|
      t.string :title
      t.string :link
      t.string :description
      t.datetime :updated
      t.integer :type
      t.string :icon

      t.timestamps null: false
    end
    add_index :feeds, :link, unique: true
  end
end
