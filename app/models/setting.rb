# frozen_string_literal: true

class Setting < ApplicationRecord
  belongs_to :user

  def latest_filtered_tenders
    Tender.last
  end

  def add_field!(key, value)
    f = filters || {}
    f[key] = value
    self.filters = f
    save!
  end
end
