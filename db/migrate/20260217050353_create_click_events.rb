class CreateClickEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :click_events do |t|
      t.references :link, null: false, foreign_key: true
      t.datetime :timestamp, null: false
      t.string :geo_country
      t.string :ip_hash
      t.string :user_agent

      t.timestamps
    end

    add_index :click_events, [ :link_id, :timestamp ]
  end
end
