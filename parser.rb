require 'mechanize'
require 'set'
require 'csv'
require './statistical'
require './category'
require './product'

class Parser
  include Statistical

  def initialize(link = 'http://www.a-yabloko.ru/')
    @agent = Mechanize.new
    @page = @agent.get(link).link_with(text: "Каталог товаров").click

    @category_level = "category"
    @products_count = 0

    @records_id = Set.new
    CSV.foreach(DB_NAME, col_sep: "\t") do |row|
      @records_id << row[4]
    end
  end

  def parse(page = @page)
    categories = page.at("div[@class='children']")
    if categories.nil?
      find_products(page)
    else
      categories = categories.css("a")
      check_categories(categories)
      categories.map do |category|
        @category_level = "subcategory"
        parse(Mechanize::Page::Link.new(category, @agent, page).click)
      end
    end
  end

  private

  def find_products(page)
    loop do
      products = page.at("table[@class='goods']").css("tr")
      check_products(products, page)
      return if page.link_with(text: "Следующая").nil?
      page = page.link_with(text: "Следующая").click
    end
  end

  def check_categories(categories)
    categories.each do |category|
      category_id = category['href']
      unless already_written?(category_id)
        Category.new(category, @category_level)
        @records_id << category_id
      end
    end
  end

  def check_products(products, page)
    products.each do |product|
      product_id = product.at("a[@class='name']")['href'].split("/")[4]
      unless already_written?(product_id)
        Product.new(product, page)
        @records_id << product_id
        @products_count += 1
        fetch_statistic if (@products_count % 1000).zero?
      end
    end
  end

  def already_written?(item_id)
    @records_id.include?(item_id)
  end

  def fetch_statistic
    return if single_category?
    print_images_statistic
    print_products_statistic
    exit!
  end
end
