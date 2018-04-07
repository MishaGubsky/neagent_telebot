
class TelegramService

  def self.send_article_messages(artiles)
    sent_api_ids = []
    user_chat_ids.each do |chat_id|
      artiles.each do |a|
        send_article_message(chat_id, a)
        sent_api_ids << a[:api_id]
      end
    end
    sent_api_ids
  end

  private

  def self.user_chat_ids
    User.subscribed.pluck(:channel_id)
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
    [:image_url, :street, :price].each {|t| send_photo_type_message(chat_id, article, t)}

    send_html_type_message(chat_id, article, :room_count, "<b>Rooms count: </b>#{article[:room_count]}")
    send_html_type_message(chat_id, article, :post_date, "<b>Post date: </b>#{article[:post_date]}")
    send_html_type_message(chat_id, article, :description, "#{article[:description]}")
    send_html_type_message(chat_id, article, :phone, "<i>#{article[:phone]}</i>")
    send_html_type_message(chat_id, article, :url, "<a href='#{article[:url]}'>ПОДРОБНЕЕ</a>")
  end
end
