require 'open-uri'

class ArticleParser
  attr_accessor :dom

  def self.parse(dom)
    new(dom).parse
  end

  def initialize(dom)
    @dom = dom
  end

  def parse
    {
      api_id: get_api_id,
      url: get_url,
      street: get_street,
      image_url: get_image_url,
      phone: get_phone,
      price: get_price,
      room_count: get_room_count,
      post_date: get_post_date,
      description: get_description
    }
  end

  private

  def get_url
    dom.css('.imd_photo a').first['href']
  rescue => e
    Rails.logger.error "Get_url failed api_id: #{get_api_id}, message: #{e.message}"
    ''
  end

  def get_street
    dom.css('.md_head em img').first && dom.css('.md_head em img').first['src'] || dom.css('.md_head em').text
  rescue => e
    Rails.logger.error "Get_street failed api_id: #{get_api_id}, message: #{e.message}"
    ''
  end

  def get_image_url
    dom.css('.imd_photo a img').first['src']
  rescue => e
    Rails.logger.error "Get_image_url failed api_id: #{get_api_id}, message: #{e.message}"
    ''
  end

  def get_post_date
    dom.css('.md_head i').first.text.gsub(/<br>/, '')
  rescue => e
    Rails.logger.error "Get_post_date failed api_id: #{get_api_id}, message: #{e.message}"
    ''
  end

  def get_room_count
    dom.css('.itm_komnat').first.text
  rescue => e
    Rails.logger.error "Get_room_count failed api_id: #{get_api_id}, message: #{e.message}"
    ''
  end

  def get_price
    new_dom = Nokogiri::HTML(open(get_url).read)
    new_dom.css('.itm_head comment()').first.text[/>([^<]*)</, 1].gsub(/&.*;/, '') || dom.css('.itm_price img').first['src']
  rescue => e
    Rails.logger.error "Get_price failed api_id: #{get_api_id}, message: #{e.message}"
    ''
  end

  def get_description
    dom.css('.imd_mess').text.strip
  rescue => e
    Rails.logger.error "Get_description failed api_id: #{get_api_id}, message: #{e.message}"
    ''
  end

  def get_api_id
    @api_id ||= dom['id'].gsub(/[^\d]+/, '')
  end

  def get_phone
    Article.get_phone(get_api_id)
  end
end
