class TelegramWebhooksController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  context_to_action!

  def start
    # byebug
    # respond_with :photo, photo: "http://fonday.ru/images/tmp/16/7/original/16710fBjLzqnJlMXhoFHAG.jpg"
  end

  def subscribe
    byebug
    subscribed = User.create(
      name: chat['first_name'],
      channel_id: chat['id'],
      subscribed: true
    )
    respond_with :message, text: "#{subscribed ? "Subscribed!" : "Something went wrong"}"
  end

  def unsubscribe
    User.find_by_channel_id(chat['id'])&.update(
      name: chat['first_name'],
      channel_id: chat['id'],
      subscribed: false
    )
  end

  def parse_force(url)
    byebug
    Article.parse_by_filters(url)
  end

  def send_parsed_force
    Article.parse_not_parsed
    articles = Article.prepare_to_send
    sent_api_ids = TelegramService.send_article_messages(articles)
    Article.balk_update_as_sent(sent_api_ids)
  end

  def clean_force
    Article.clean
  end
end
