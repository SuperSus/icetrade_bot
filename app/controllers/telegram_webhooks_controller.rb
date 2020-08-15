class TelegramWebhooksController < Telegram::Bot::UpdatesController
  before_action :find_user, only: %i[keyboard!]

  def start!(*)
    user = User.find_or_create_by(chat_id: chat['id'], name: chat['username'])
    respond_with :message, text: t('.hi', name: user.name || '')
  end

  private

  def find_user
    @user = User.find_or_create_by(chat_id: chat['id'])
  end
end
