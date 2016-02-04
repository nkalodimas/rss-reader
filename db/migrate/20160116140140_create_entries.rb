class CreateEntries < ActiveRecord::Migration
  def change
    create_table :entries do |t|
      t.string :title
      t.string :link
      t.string :summary
      t.datetime :pub_date
      t.string :entryId
      t.references :feed, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
