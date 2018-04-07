class User < ApplicationRecord
  has_many :user_filters
  has_many :filters, through: :user_filters

  validates :channel_id, uniqueness: true

  scope :subscribed, -> { where(subscribed: true) }
end
