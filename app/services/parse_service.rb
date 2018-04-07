class ParseService
  attr_accessor :dom

  def self.parse(url)
    new(url).parse
  end

  def initialize(url)
    @dom = Nokogiri::HTML(open(url).read)
  end

  def parse
    dom.css('.imd').map {|a| ArticleParser.parse(a)}
  end
end
