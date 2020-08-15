class Message
  include ActiveModel::Model

  attr_accessor :tender

  validates :tender, presence: true

  def to_s
    <<~MSG
      *#{tender.header}*

      #{tender.url}
    MSG
  end
end
