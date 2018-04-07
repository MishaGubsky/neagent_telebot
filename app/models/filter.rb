class Filter < ApplicationRecord
    has_many :user_filters
    has_many :users, through: :user_filters

    validates :name, uniqueness: true
end
