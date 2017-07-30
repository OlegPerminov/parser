require 'mechanize'
require 'securerandom'

class Item
  attr_accessor :type, :name, :group_name, :icon_name, :id
end

class Product < Item

  @@products_count = 1

  def initialize(product, page)
    @type = "product"
    @name = product.at("a[@class='name']").text
    @group_name = page.at("div[@id='tips']").text.split("/")[2]
    @icon_name = SecureRandom.uuid + ".jpg"
    @id = product.at("a[@class='name']")['href'].split("/")[4]

    @@products_count += 1

    icon_url = page.uri + product.at("a[@class='img']")['rel']
    self.save_image(icon_url)
  end

  def self.products_count
    @@products_count
  end

  def save_image(icon_url)
    img = Mechanize.new.get(icon_url)
    img.save("./images/#{@icon_name}")
  end
end

class Category < Item

  @@level = 0

  def initialize(category)
    @type = self.check_category
    @name = category.text.gsub(/[\d\t]/, "")
    @group_name = "-"
    @icon_name = SecureRandom.uuid + ".jpg"
    @id = category['href']
  end

  def self.up_level
    @@level += 1
  end

  def check_category
    @@level < 1 ? "category" : "subcategory"
  end
end
