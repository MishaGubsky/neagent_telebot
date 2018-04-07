class AddFieldsToArticles < ActiveRecord::Migration[5.1]
  def change
    add_column :articles, :api_id, :text
    add_column :articles, :street, :text
    add_column :articles, :price, :text
    add_column :articles, :phone, :text
    add_column :articles, :room_count, :text
    add_column :articles, :post_date, :text
    add_column :articles, :description, :text
    add_column :articles, :image_url, :text
    add_column :articles, :sent, :boolean
  end
end
