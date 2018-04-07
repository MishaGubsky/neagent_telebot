class Article < ApplicationRecord
  validates :api_id, uniqueness: true

  scope :parsed, -> { where(parsed: true) }
  scope :not_parsed, -> { where(parsed: false) }
  scope :ready_to_show, -> { where(parsed: true, sent: false) }
  scope :sent, -> { where(sent: true) }

  def self.get_phone(api_id)
    link = "http://neagent.by/realt/showphone/#{api_id}"
    response = JSON.parse(URI.parse(link).read)
    (response['phones'] =~ /<[a-z\/][\s\S]*>/) ? '' : response['phones']
  rescue => e
    Rails.logger.warn "Phone is still unavaliable api_id: #{api_id}, message: #{e.message}"
    ''
  end

  def self.parse_not_parsed
    Article.not_parsed.each do |a|
      phone = Article.get_phone(a.api_id)
      a.update(parsed: true) if phone.present?
    end
  end

  def self.parse_by_filters(link)
    articles = ParseService.parse(link)
    as_for_save = articles.map do |a|
      a[:image_url] = ImageService.upload(a[:image_url], 'image_url', a[:api_id]) if base64?(a[:image_url])
      a[:price] = ImageService.upload(a[:price], 'price', a[:api_id]) if base64?(a[:price])
      a[:street] = ImageService.upload(a[:street], 'street', a[:api_id]) if base64?(a[:street])
      a[:phone] && a[:api_id] ? a.merge({parsed: true}) : a
    end
    Article.create(as_for_save)
  end

  def self.prepare_to_send
    ready_to_show.map do |a|
      a.attributes.symbolize_keys.merge({
        image_url: a.is_local?('image_url', a.image_url) ? ImageService.read(a.image_url) : a.image_url,
        price: a.is_local?('price', a.price) ? ImageService.read(a.price) : a.price,
        street: a.is_local?('street', a.street) ? ImageService.read(a.street) : a.street
      })
    end
  end

  def is_local?(type, path)
    "public/photos/#{type}-#{api_id}.png" == path
  end

  def self.base64?(value)
    value.is_a?(String) && value =~ /\Adata:image/
  end

  def self.bulk_update_as_sent(sent_api_ids)
    Article.where("articles.api_id in (#{sent_api_ids.join(', ')})").update_all(sent: true) unless sent_api_ids.empty?
  end

  def self.clean
    types = ['image_url', 'price', 'street']
    sent.each do |a|
      types.each { |t| File.delete(a.send(t)) if a.is_local?(t, a.send(t)) && File.exist?(a.send(t)) }
    end
    sent.delete_all
  end
end
