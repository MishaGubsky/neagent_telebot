
class TelegrammNotifier

  def self.send_article_messages(articles)
    sent_api_ids = []
    articles.each do |a|
      user_chat_ids(a).each do |chat_id|
        send_article_message(chat_id, a)
        sent_api_ids << a[:api_id]
      end
    end
    sent_api_ids
  end

  private

  def self.user_chat_ids(article)
    with_filters = User.subscribed.with_filters
    without_filters = User.subscribed.without_filters
    Filter.all.each do |f|
      with_filters = with_filters.send(:"#{f.filter_type}_filter", f, article[:normolized_price])
    end
    users = without_filters + with_filters
    users.pluck(:channel_id)
  end

  def self.send_photo_type_message(chat_id, article, type)
    Telegram.bot.send_photo(chat_id: chat_id, photo: article[type]) if article[type].present?
  rescue => e
    Rails.logger.error "Sending failed api_id: #{article[:api_id]}, type:#{type}, message: #{e.message}"
  end

  def self.send_html_type_message(chat_id, article, type, value=nil)
    Telegram.bot.send_message(chat_id: chat_id, text: value || article[type], parse_mode: "HTML") if value || article[type]
  rescue => e
    Rails.logger.error "Sending failed api_id: #{article[:api_id]}, type:#{type}, message: #{e.message}"
  end

  def self.send_article_message(chat_id, article)
    send_photo_type_message(chat_id, article, :image_url)

    [:street, :price].each do |t|
      send_photo_type_message(chat_id, article, t) if article[:price].class != String
      send_html_type_message(chat_id, article, t, "<b>#{t.upcase}: </b>#{article[t]}") if article[t].class == String
    end

    send_html_type_message(chat_id, article, :room_count, "<b>Rooms count: </b>#{article[:room_count]}")
    send_html_type_message(chat_id, article, :post_date, "<b>Post date: </b>#{article[:post_date]}")
    send_html_type_message(chat_id, article, :description, "#{article[:description]}")
    send_html_type_message(chat_id, article, :phone, "<i>#{article[:phone]}</i>")
    send_html_type_message(chat_id, article, :url, "<a href='#{article[:url]}'>ПОДРОБНЕЕ</a>")
  end
end
