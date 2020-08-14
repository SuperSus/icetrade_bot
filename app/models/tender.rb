# frozen_string_literal: true

class Tender < ApplicationRecord
  FILTER_KEYS = [
    'branch'
  ].freeze

  FIELDS_TEMPLATE = '(fields ->> %<key>s = %<value>s)'

  validates :url, presence: true, uniqueness: true

  scope :fields_eq, ->(key, value) do
    values = value.split(/[\s,]+/).reject(&:empty?)
    return all unless values.present?

    # use connection quote to prevent possible SQL injections
    connection = ActiveRecord::Base.connection
    quoted_key = connection.quote(key)

    # allowing multiple values separated by commas
    comparison_expression = values.map do |val|
      quoted_value = connection.quote(val.strip)
      format(FIELDS_TEMPLATE, key: quoted_key, value: quoted_value)
    end.join(" OR ")

    where("fields ? #{quoted_key} AND (#{comparison_expression})")
  end

  def add_field!(key, value)
    f = fields || {}
    f[key] = value
    self.fields = f
    save!
  end
end
