class UserFilter < ApplicationRecord
  belongs_to :user
  belongs_to :filter

  validates :user, uniqueness: {scope: :filter}

  scope :subscribed_users, -> { joins(:user).where("users.subscribed"=> true) }
end
