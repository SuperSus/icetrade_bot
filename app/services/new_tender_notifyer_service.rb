# frozen_string_literal: true

class NewTenderNotifyerService
  LIMIT_TENDERS_TO_SEND = 5

  def call
    Setting.includes(:user).find_each do |setting|
      last_tenders_ids = last_tenders_ids(setting)
      next if last_tenders_ids.last == setting.last_sended_tender_id

      last_tenders_ids.each do |tender_id|
        tender = Tender.find(tender_id)
        msg = prepare_msg(tender)

        send_message(setting.user.chat_id, msg)
      end

      setting.update(last_sended_tender_id: last_tenders_ids.last)
    end
  end

  private

  def send_message(chat_id, msg)
    Telegram.bot.send_message(chat_id: chat_id, text: msg, parse_mode: 'Markdown')
  end

  def prepare_msg(tender)
    "hey"
  end

  def last_tenders_ids(setting)
    Tender.order(id: :desc).limit(LIMIT_TENDERS_TO_SEND).pluck(:id)
  end
end
