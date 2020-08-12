class Setting < ApplicationRecord
  belongs_to :user

  serialize :key_words, Array
  serialize :filters, Hash
end
