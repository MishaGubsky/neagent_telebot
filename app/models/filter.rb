class Filter < ApplicationRecord
    has_many :user_filters
    has_many :users, through: :user_filters

    validates :key, uniqueness: true

    enum filter_type: [:bool, :less_then, :more_then, :included]
end
