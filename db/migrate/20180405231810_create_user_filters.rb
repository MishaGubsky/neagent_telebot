class CreateUserFilters < ActiveRecord::Migration[5.1]
  def change
    create_table :user_filters do |t|
      t.belongs_to :user
      t.belongs_to :filter
      t.string :text

      t.timestamps
    end
  end
end
