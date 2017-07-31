require 'mechanize'
require 'securerandom'
require './item'

class Product < Item
  @@products_count = 0

  def initialize(product, page)
    @type = "product"
    @name = product.at("a[@class='name']").text
    @group_name = page.at("div[@id='tips']").text.split("/")[2]
    @icon_name = SecureRandom.uuid + "." +
                 product.at("a[@class='img']")['rel'].split("/")[-1].split(".")[-1]
    @id = product.at("a[@class='name']")['href'].split("/")[4]

    @@products_count += 1

    icon_url = "http://www.a-yabloko.ru" + product.at("a[@class='img']")['rel']
    save_image(icon_url)
  end

  def self.products_count
    @@products_count
  end

  def save_image(icon_url)
    img = Mechanize.new.get(icon_url)
    img.save("./images/#{@icon_name}")
  end
end
