# frozen_string_literal: true

class User < ApplicationRecord
  has_one :setting

  before_create :initialize_setting

  private

  def initialize_setting
    build_setting
  end
end
