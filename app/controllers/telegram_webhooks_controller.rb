class TelegramWebhooksController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext

  INDUSTRIES = [
    'Авиация',
    'Аукционы',
    'Банки',
    'Безопасность',
    'Бизнес / финансы / страхование',
    'Ветеринария',
    'Геодезия / картография',
    'Геология / сейсмология',
    'Горнорудная промышленность',
    'Железная дорога',
    'ЖКХ / бытовое обслуживание',
    'Информационные технологии',
    'Компьютеры / оборудование',
    'Культура',
    'Легкая промышленность',
    'Лесное хозяйство / деревообрабатывающая промышленность',
    'Маркетинг / реклама',
    'Машиностроение',
    'Медицина',
    'Металлы / металлоизделия',
    'Недвижимость',
    'Образование / наука',
    'Офис / дом',
    'Перевозки / логистика / таможня',
    'Полиграфическая / издательская деятельность',
    'Продовольствие / пищевая промышленность',
    'Проектирование',
    'Связь / коммуникации',
    'Сельское хозяйство',
    'Строительство / архитектура',
    'Сырье / материалы',
    'Тарное хозяйство',
    'Топливо / нефтехимия',
    'Торговля',
    'Транспорт',
    'Туризм / отдых / спорт',
    'Фармакология',
    'Химия',
    'Целлюлозно-бумажное производство',
    'Экология',
    'Электроника / бытовая техника',
    'Электротехника',
    'Энергетика'
  ].freeze

  before_action :find_user

  def start!(*)
    user = User.find_or_create_by(chat_id: chat['id'], name: chat['username'])
    respond_with :message, text: translation('start.hi', name: user.name || '')
  end

  def keyboard!(value = nil, *)
    if value
      if value == main_menu_buttons[:settings]
        respond_with :message, text: translation('settings_inline_keyboard.prompt'), reply_markup: update_settings_keyboard_markup
      else
        # respond_with :message, text: t('.selected', value: value)
      end
    else
      save_context :keyboard!
      respond_with :message, text: translation('main_menu.prompt'), reply_markup: main_keyboard_markup
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
    respond_with :message, text: translation('change_keywords', keywords: @user.setting.keywords)
  end

  def apply_keywords(*args)
    keywords = args.join.split(/[,\.\s]+/)
    @user.setting.keywords = keywords
    @user.save

    save_context nil
    respond_with :message, text: translation('apply_keywords.done', keywords: @user.setting.keywords)
  end

  def сhoose_industry(*params)
    respond_with :message, text: translation('choose_industry.prompt'), reply_markup: choose_industry_keyboard_markup
  end

  INDUSTRIES.each_with_index do |_indusry, id|
    define_method("choose_industry_#{id}") do
      # session[:choose_industry_buttons_state] = nil
      db_selected_ids = @user.setting.industries
                             .map { |industry| INDUSTRIES.index(industry) }
                             .compact
                             .map { |id| [id, true] }
                             .to_h
      session[:choose_industry_buttons_state] ||= db_selected_ids
      # toggle
      session[:choose_industry_buttons_state][id] = !session[:choose_industry_buttons_state][id]

      selected_ids = session[:choose_industry_buttons_state].select { |_id, value| value }.keys
      edit_message :reply_markup, reply_markup: choose_industry_keyboard_markup(selected_ids)
    end
  end

  def apply_industry
    if session[:choose_industry_buttons_state]
      selected_ids = session[:choose_industry_buttons_state].select { |_id, value| value }.keys
      industries = INDUSTRIES.values_at(*selected_ids)

      @user.setting.add_industries!(industries)
      session[:choose_industry_buttons_state] = nil
    end

    respond_with :message, text: translation('apply_industry.done'), reply_markup: main_keyboard_markup
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
    options = translation('settings_inline_keyboard.choose_options')
    {
      inline_keyboard: [
        [{ text: options[:change_keywords], callback_data: 'change_keywords' }],
        [{ text: options[:сhoose_industry], callback_data: 'сhoose_industry' }]
      ]
    }
  end

  def choose_industry_keyboard_markup(selected_ids = [])
    industries_buttons = INDUSTRIES.each_with_index.map do |name, id|
      selected = selected_ids.include?(id)

      { text: selected ? "\xE2\x9C\x85 #{name}" : name, callback_data: "choose_industry_#{id}" }
    end

    industries_buttons_grid = industries_buttons
                              .each_slice(2)
                              .map { |buttons_group| buttons_group }

    done_button_text = translation('apply_industry.buttons.done')
    done_button = [{ text: done_button_text, callback_data: 'apply_industry' }]

    {
      inline_keyboard: [
        *industries_buttons_grid,
        done_button
      ]
    }
  end

  def main_menu_buttons
    t('telegram_webhooks.main_menu.buttons')
  end

  def translation(path, params = {})
    t("telegram_webhooks.#{path}", params)
  end

  def handle_update_settings
    @user.setting
    respond_with :message, text: translation('settings_inline_keyboard.prompt'), reply_markup: update_settings_keyboard_markup
  end

  def invoke_action(action, *args)
    send(action, *args) if respond_to?(action, true)
  end
end
