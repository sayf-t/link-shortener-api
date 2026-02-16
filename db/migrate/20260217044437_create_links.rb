class CreateLinks < ActiveRecord::Migration[8.1]
  def change
    create_table :links do |t|
      t.string :short_code, null: false, limit: 15
      t.string :target_url, null: false
      t.string :title

      t.timestamps
    end

    add_index :links, :short_code, unique: true
  end
end
