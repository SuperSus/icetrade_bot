# frozen_string_literal: true

class Setting < ApplicationRecord
  belongs_to :user

  def filtered_tenders
    return Tender.all unless keywords.any?

    Tender.search_any_word(keywords.join(' '))
  end

  def add_field!(key, value)
    f = filters || {}
    f[key] = value
    self.filters = f
    save!
  end
end
