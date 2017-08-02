require 'mechanize'
require 'securerandom'

class Product
  def initialize(product, page)
    @type = "product"
    @name = product.at("a[@class='name']").text
    @group_name = page.at("div[@id='tips']").text.split("/")[2]
    @icon_name = SecureRandom.uuid + "." +
                 product.at("a[@class='img']")['rel'].split("/")[-1].split(".")[-1]
    @id = product.at("a[@class='name']")['href'].split("/")[4]

    icon_url = "http://www.a-yabloko.ru" + product.at("a[@class='img']")['rel']
    save_image(icon_url)
    write_data
  end

  def save_image(icon_url)
    img = Mechanize.new.get(icon_url)
    img.save("./images/#{@icon_name}")
  end

  def write_data
    line = "#{@type}\t#{@name}\t#{@group_name}\t#{@icon_name}\t#{@id}"
    File.open("catalog.txt", "a") { |file| file.puts line.delete("\"") }
  end
end
