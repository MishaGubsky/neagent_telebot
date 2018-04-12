class TelegramWebhooksController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  context_to_action!

  def start
    respond_with :message, text: "Hey, #{chat['first_name']}\nLet's subcribe to start enjoy this app:\nIt's very easy just send me: /subscribe\n\nIf you have any questions first visit: /help\n\nAnd only then contact with me: test@test.com"
  end

  def subscribe
    user = User.create_with(name: chat['first_name']).find_or_create_by(channel_id: chat['id'])
    user.subscribed = true
    subscribed = user.save
    respond_with :message, text: "#{subscribed ? "Subscribed!" : "Something went wrong"}"
  end

  def unsubscribe
    return unless check_subscription
    unsubscribed = User.find_by_channel_id(chat['id'])&.update(
      name: chat['first_name'],
      channel_id: chat['id'],
      subscribed: false
    )
    respond_with :message, text: "#{unsubscribed ? "Unsubscribed!" : "Something went wrong"}"
  end

  def parse_force(url) # TODO: build url according to exist filters + sort by date: order=postdate_za
    Article.parse_by_filters(url)
  end

  def send_parsed_force
    Article.parse_not_parsed
    articles = Article.prepare_to_send
    sent_api_ids = TelegrammNotifier.send_article_messages(articles)
    Article.bulk_update_as_sent(sent_api_ids)
  end

  def clean_force
    Article.clean
  end

  # filters
  def add_filters(*filters_params)
    return unless check_subscription

    hash = filters_params.map{ |filter| filter.split(':')}.to_h
    filters = get_filters_by_keys(hash.keys)
    user_filters = filters.map {|f| UserFilter.create(user: current_user, filter: f, text: hash[f.key])}
    response(!user_filters.empty?)
  end

  def filter_list
    return unless check_subscription

    filters = current_user.user_filters.includes(:filter).map {|user_filter| "#{user_filter.filter.key}: #{user_filter.text}" }
    filters = filters.empty? ? ["Your filter list is empty"] : ["Your filter list:"] + filters
    respond_with :message, text: filters.join("\n")
  end

  def change_filters
    return unless check_subscription
  end

  def remove_filters(*params)
    return unless check_subscription

    success = get_filters_by_keys(params).each {|f| UserFilter.where(user:current_user, filter: f).delete_all()}
    response(success)
  end

  def help(*)
    respond_with :message, text: "/subscribe - The system remembers you and will send you notifications about new posts\n\n/unsubscribe - To unsubscribe from notifications\n\n/parse_force(url) - Start force parsing one of neagent's pages\n\n/send_parsed_force - Force send notifications about new parsed article\n\n/clean_force - Clean temp files\n\n# Filters\n\n/filter_list - List of yours filters\n\n/add_filters(a[, b[,..) - Add filter value. The parameter should be like: KEY:value. Each parameter through a space.\n\n/remove_filters(k1[, k2[,) - Remove your filter. The params k1, k2... KEYS of filters."
  end

  private

  def response(success)
    respond_with :message, text: "#{success ? "Done!" : "Something went wrong"}"
  end

  def get_filters_by_keys(keys)
    keys.count > 1 ? Filter.where("filters.key in (#{keys.join(',')})") : Filter.where(key: keys[0])
  end

  def current_user
    @current_user = User.find_by_channel_id(chat['id'])
  end

  def check_subscription
    return respond_with(:message, text: "For this action you should subscribe") && false unless current_user&.subscribed
    return true
  end

end
