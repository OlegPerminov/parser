require 'securerandom'
require './item'

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
