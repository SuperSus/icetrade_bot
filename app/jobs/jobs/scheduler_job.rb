class SchedulerJob < CronJob
  # set the (default) cron expression
  self.cron_expression = '* * * * *'

  # will enqueue the mailing delivery job
  def perform
    msg = IceTradeService.new.call
    last_msg = Rails.cache.read('last_msg')

    return if last_msg == msg

    Rails.cache.write('last_msg', msg)

    User.all.each do |user|
      Telegram.bot.send_message(chat_id: user.chat_id, text: msg, parse_mode: 'Markdown')
    end
  end
end
