# frozen_string_literal: true

class Subscription < ApplicationRecord
  belongs_to :user
  has_many :payments

  TYPES = %i[
    month
    three_month
  ].freeze

  COSTS = {
    month: 10,
    three_month: 20
  }.freeze

  PERIODS = {
    free_tier: 10.days,
    month: 1.month,
    three_month: 3.month
  }.freeze

  class << self
    def build_with_free_tier(user_id)
      new(
        user_id: user_id,
        payed_for: DateTime.now + PERIODS[:free_tier]
      )
    end
  end

  def renew!
    Subscription.transaction do
      payments.not_used.each do |payment|
        update_payed_for!(PERIODS[payment.subcription_type])
        payment.use!
      end
    end
  end

  private

  def update_payed_for!(period)
    now = DateTime.now
    if payed_for
      start_time = payed_for > now ? payed_for : now
    else
      start_time = now 
    end
    new_payed_for = start_time + period

    update(payed_for: new_payed_for)
  end
end
