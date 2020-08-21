# frozen_string_literal: true

class Setting < ApplicationRecord
  belongs_to :user

  scope :active, -> { where(active: true) }

  def filtered_tenders
    Tender.by_industries(industries).by_keywords(keywords)
  end

  def industries
    f = filters || {}
    f['industries'] ||= []
  end

  # only users with active settings will be notifyed
  def activate!
    update(active: true)
  end

  def deactivate!
    update(active: false)
  end

  def add_industries!(industries)
    add_filter!('industries', industries)
  end

  def reset_industries!
    add_filter!('industries', [])
  end

  def add_filter!(key, value)
    f = filters || {}
    f[key] = value
    self.filters = f
    save!
  end

  def pretty_keywords
    keywords.join(", ")
  end
end
