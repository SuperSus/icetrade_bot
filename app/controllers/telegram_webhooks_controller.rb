class TelegramWebhooksController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext

  before_action :find_user

  def start!(*)
    user = User.find_or_create_by(chat_id: chat['id'], name: chat['username'])
    respond_with :message, text: t('.hi', name: user.name || '')
  end

  def keyboard!(value = nil, *)
    if value
      if value == main_menu_buttons[:settings]
        respond_with :message, text: t('.inline_keyboard.prompt'), reply_markup: update_settings_keyboard_markup
      else
        respond_with :message, text: t('.selected', value: value)
      end
    else
      save_context :keyboard!
      respond_with :message, text: t('.main_menu.prompt'), reply_markup: main_keyboard_markup
    end
  end

  def hhh!(*)
    binding.pry
  end

  def message(message); end

  def callback_query(action)
    invoke_action(action)
  end

  # Actions

  def change_keywords
    save_context :apply_keywords
    respond_with :message, text: t('.change_keywords', keywords: @user.setting.keywords)
  end

  def apply_keywords(*args)
    keywords = args.join.split(/[,\.\s]+/)
    @user.setting.keywords = keywords
    @user.save

    save_context nil
    respond_with :message, text: t('.', keywords: @user.setting.keywords)
  end

  def сhoose_industry(*params)
    respond_with :message, text: 'llll', reply_markup: choose_industry_keyboard_markup
  end

  [1, 2].each do |id|
    define_method("choose_industry_#{id}") do
      session[:choose_industry_buttons_state] ||= {}
      # toggle
      session[:choose_industry_buttons_state][id] = !session[:choose_industry_buttons_state][id]

      selected_ids = session[:choose_industry_buttons_state].select { |_id, value| value }.keys
      edit_message :reply_markup, reply_markup: choose_industry_keyboard_markup(selected_ids)
    end
  end

  private

  def find_user
    @user = User.find_or_create_by(chat_id: chat['id'])
  end

  def main_keyboard_markup
    buttons = main_menu_buttons.values_at(:settings, :start_search)
    {
      keyboard: [buttons],
      resize_keyboard: true,
      one_time_keyboard: true,
      selective: true
    }
  end

  def update_settings_keyboard_markup
    options = t('.inline_keyboard.choose_options')
    {
      inline_keyboard: [
        [{ text: options[:change_keywords], callback_data: 'change_keywords' }],
        [{ text: options[:сhoose_industry], callback_data: 'сhoose_industry' }]
      ]
    }
  end

  def choose_industry_keyboard_markup(selected_ids = [])
    industries = [{ id: 1, text: "blah1" }, { id: 2, text: "blah2" }]
    industries_buttons = industries.to_a.map do |industry|
      id, text = industry.values_at(:id, :text)
      selected = selected_ids.include?(id)

      [{ text: selected ? "#{text} v" : text, callback_data: "choose_industry_#{id}" }]
    end

    done_button = [{ text: 'done', callback_data: 'apply_industry' }]

    {
      inline_keyboard: [
        *industries_buttons,
        done_button
      ]
    }
  end

  def main_menu_buttons
    t('.main_menu.buttons')
  end

  def handle_update_settings
    @user.setting
    respond_with :message, text: t('.inline_keyboard.prompt'), reply_markup: update_settings_keyboard_markup
  end

  def invoke_action(action, *args)
    send(action, *args) if respond_to?(action, true)
  end
end
