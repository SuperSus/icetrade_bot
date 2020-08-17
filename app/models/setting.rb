# frozen_string_literal: true

class Setting < ApplicationRecord
  belongs_to :user

  def filtered_tenders
    Tender.by_industries(industries).search_any_word(keywords.join(' '))
  end

  def industries
    f = filters || {}
    f['industries']
  end

  def add_industries!(industries)
    add_filter!('industries', industries)
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
