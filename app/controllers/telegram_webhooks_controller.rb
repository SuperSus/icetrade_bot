class TelegramWebhooksController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext

  before_action :find_user

  def start!(*)
    user = User.find_or_create_by(chat_id: chat['id'], name: chat['username'])
    respond_with_markdown_meesage(text: translation('start.hi', name: user.name || ''))
  end

  def keyboard!(value = nil, *)
    save_context :keyboard!
    if value
      if value == main_menu_buttons[:settings]
        show_settings_menu
      else
        # respond_with_markdown_meesage(text: t('.selected', value: value))
      end
    else
      respond_with_markdown_meesage(text: translation('main_menu.prompt'), reply_markup: main_keyboard_markup)
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
    respond_with_markdown_meesage(
      text: translation('change_keywords', keywords: @user.setting.pretty_keywords),
      reply_markup: back_button_inline('show_settings_menu')
    )
  end

  def show_settings_menu
    save_context :keyboard!
    respond_with_markdown_meesage(text: translation('settings_inline_keyboard.prompt'), reply_markup: update_settings_keyboard_markup)
  end

  def apply_keywords(*args)
    keywords = args.join(', ').split(/[,\.\s]+/)
    @user.setting.keywords = keywords
    @user.save

    save_context :keyboard!
    respond_with_markdown_meesage(text: translation('apply_keywords.done', keywords: @user.setting.pretty_keywords), reply_markup: main_keyboard_markup)
  end

  def сhoose_industry
    respond_with_markdown_meesage(text: translation('choose_industry.prompt'), reply_markup: choose_industry_keyboard_markup(slected_industries_ids))
  end

  # methaprogrammig! define methods like choose_industry_1, choose_industry_2 for each industry
  Industry::INDUSTRIES.each_with_index do |_indusry, id|
    define_method("choose_industry_#{id}") do
      industries_buttons_state[id] = !industries_buttons_state[id]
      edit_message :reply_markup, reply_markup: choose_industry_keyboard_markup(slected_industries_ids)
    end
  end

  def apply_industry
    industries = Industry::INDUSTRIES.values_at(*slected_industries_ids)
    @user.setting.add_industries!(industries)
    destroy_industries_buttons_state

    save_context :keyboard!
    respond_with_markdown_meesage(text: translation('apply_industry.done'), reply_markup: main_keyboard_markup)
  end

  private

  def find_user
    @user = User.find_or_create_by(chat_id: chat['id'])
  end

  def respond_with_markdown_meesage(params={})
    respond_with :message, params.merge(parse_mode: 'Markdown')
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

  def back_button_inline(callback_data = 'keyboard!')
    { inline_keyboard: [back_button(callback_data)] }
  end

  def back_button(callback_data = 'keyboard!')
    [{ text: translation('back_button'), callback_data: callback_data }]
  end

  def update_settings_keyboard_markup
    options = translation('settings_inline_keyboard.choose_options')
    edit_icon = "\xE2\x9C\x8F"
    industry_icon = "\xF0\x9F\x92\xBC"
    {
      inline_keyboard: [
        [{ text: "#{options[:change_keywords]}  #{edit_icon}", callback_data: 'change_keywords' }],
        [{ text: "#{options[:сhoose_industry]}  #{industry_icon}", callback_data: 'сhoose_industry' }],
        back_button('keyboard!')
      ]
    }
  end

  def choose_industry_keyboard_markup(selected_ids = [])
    industries_buttons = Industry::INDUSTRIES.each_with_index.map do |name, id|
      check_icon = "\xE2\x9C\x85"
      selected = selected_ids.include?(id)
      { text: selected ? "#{check_icon} #{name}" : name, callback_data: "choose_industry_#{id}" }
    end

    industries_buttons_grid = industries_buttons
                              .each_slice(2)
                              .map { |buttons_group| buttons_group }

    done_button_text = translation('apply_industry.buttons.done')
    done_button = [{ text: done_button_text, callback_data: 'apply_industry' }]

    {
      inline_keyboard: [
        *industries_buttons_grid,
        done_button,
        back_button('show_settings_menu')
      ]
    }
  end

  def main_menu_buttons
    t('telegram_webhooks.main_menu.buttons')
  end

  def translation(path, params = {})
    t("telegram_webhooks.#{path}", params)
  end

  def invoke_action(action, *args)
    send(action, *args) if respond_to?(action, true)
  end

  def industries_buttons_state
    session[:choose_industry_buttons_state] ||= begin
      @user.setting.industries
           .map { |industry| Industry::INDUSTRIES.index(industry) }
           .compact
           .map { |id| [id, true] }
           .to_h
    end
  end

  def slected_industries_ids
    return [] unless industries_buttons_state.present?

    industries_buttons_state.select { |_id, value| value }.keys
  end

  def destroy_industries_buttons_state
    session[:choose_industry_buttons_state] = nil
  end
end
