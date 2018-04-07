class CreateArticles < ActiveRecord::Migration[5.1]
  def change
    create_table :articles do |t|
      t.string :url
      t.boolean :parsed, default: false

      t.timestamps
    end
  end
end
