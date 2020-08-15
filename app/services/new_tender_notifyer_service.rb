# frozen_string_literal: true

class NewTenderNotifyerService
  LIMIT_TENDERS_TO_SEND = 5

  def call
    Setting.includes(:user).find_each do |setting|
      last_tenders = last_tenders(setting)
      latest_tender_id = last_tenders.first.id
      next if latest_tender_id == setting.last_sended_tender_id

      last_tenders.each do |tender|
        msg = prepare_msg(tender)

        send_message(setting.user.chat_id, msg)
      end

      setting.update(last_sended_tender_id: latest_tender_id)
    end
  end

  private

  def send_message(chat_id, msg)
    Telegram.bot.send_message(chat_id: chat_id, text: msg, parse_mode: 'Markdown')
  end

  def prepare_msg(_tender)
    'hey'
  end

  # latest fetched tenders the first is newest
  def last_tenders(setting)
    setting
      .filtered_tenders.order(id: :desc)
      .limit(LIMIT_TENDERS_TO_SEND)
  end
end
