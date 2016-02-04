class CreateReads < ActiveRecord::Migration
  def change
    create_table :reads do |t|
      t.boolean :read, default: false
      t.references :user, index: true, foreign_key: true
      t.references :entry, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
