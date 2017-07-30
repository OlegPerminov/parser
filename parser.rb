require 'mechanize'
require 'csv'
require './item'
require './statistical'

class Parser

  include Statistical

  def initialize(link = 'http://www.a-yabloko.ru/')
    @agent = Mechanize.new
    @page = @agent.get(link).link_with(text: "Каталог товаров").click
    @uri = @page.uri
  end

  def parse(page = @page)
    categories = page.at("div[@class='children']")
    unless categories.nil?
      categories = categories.css("a")
      categories.map do |category|
        unless already_written?(category['href'])
          write_data(Category.new(category))
        end
        @uri + category['href']
      end

      categories.map do |category|
        Category.up_level
        category = parse(Mechanize::Page::Link.new(category, @agent, page).click)
      end
    else
      find_products(page)
    end
  end

  private

  def find_products(page)
    while(true)
      product_links = page.at("table[@class='goods']").css("tr")
      product_links.each do |product|
        unless already_written?(product.at("a[@class='name']")['href'].split("/")[4])
          write_data(Product.new(product, page))
          check_product_quantity
        end
      end
      return if page.link_with(text: "Следующая") == nil
      page = page.link_with(text: "Следующая").click
    end
  end

  def already_written?(item_id)
    return false if File.zero?(DB_NAME) || !File.exist?(DB_NAME)
    items = {}
    CSV.foreach(DB_NAME, { :col_sep => "\t" }) do |row|
      items[row[4]] = true unless row.empty?
    end
    items[item_id]
  end

  def write_data(item)
    line = "#{item.type}\t#{item.name}\t#{item.group_name}\t#{item.icon_name}\t#{item.id}"
    File.open(DB_NAME, "a") { |file| file.puts line.gsub("\"", "") }
  end

  def check_product_quantity
    print_statistics if Product.products_count % 1000 == 0
  end
end

my_parser = Parser.new
my_parser.parse