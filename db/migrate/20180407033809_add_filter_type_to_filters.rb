class AddFilterTypeToFilters < ActiveRecord::Migration[5.1]
  def change
    add_column :filters, :filter_type, :integer, default: 0
    add_column :filters, :key, :string, uniqueness: true
  end
end
