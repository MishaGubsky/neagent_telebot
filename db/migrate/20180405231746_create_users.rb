class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :name
      t.integer :channel_id
      t.boolean :subscribed, default: false

      t.timestamps
    end
  end
end
