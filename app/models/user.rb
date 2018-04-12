class User < ApplicationRecord
  has_many :user_filters
  has_many :filters, through: :user_filters

  validates :channel_id, uniqueness: true

  scope :subscribed, -> { where(subscribed: true) }

  scope :bool_filter, -> (filter, value) { joins(:user_filters).where(filter_id: filter.id, text: value) }
  scope :less_then_filter, -> (filter, value) { joins(:user_filters).where("filter_id=#{filter.id} and CAST(user_filters.text AS SIGNED) >= #{value&.to_i}") }
  scope :more_then_filter, -> (filter, value) { joins(:user_filters).where("filter_id=#{filter.id} and CAST(user_filters.text AS SIGNED) <= #{value&.to_i}") }

  scope :included_filter, -> (filter, value) { where("filter_id=#{filter.id} and #{value&.to_i} in (text)") }


  scope :with_filters, -> { joins(:user_filters) }
  scope :without_filters, -> { left_outer_joins(:user_filters).where( user_filters: { id: nil } ) }
end
