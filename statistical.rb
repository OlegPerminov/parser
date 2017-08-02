require 'csv'

module Statistical
  IMG_FOLDER = "./images"
  DB_NAME = "catalog.txt"

  def print_images_statistic
    content = Dir[IMG_FOLDER + "/*"]
    images_sizes = content.map { |file| File.size(file) }
    total_size = images_sizes.inject(:+)

    puts "Images parameters:"
    puts "Average image size: #{(total_size / images_sizes.length).to_i} B"
    puts "Minimum image size: #{images_sizes.min} B"
    puts "Maximum image size: #{images_sizes.max} B"

    puts "\nPercent of products which has image is " \
         "#{((1 - count_empty_images(images_sizes).to_f / content.size) * 100).round(2)}%"
  end

  def print_products_statistic
    products = count_products
    total = products.values.inject(:+)
    puts "\nProducts statistics:"
    products.each do |category, product_quantity|
      puts "Category: #{category} contains #{product_quantity} products. " \
           "It's a #{(product_quantity.to_f / total * 100).round(2)}% of total."
    end
  end

  def single_category?
    count_products.size == 1
  end

  private

  def count_products
    database = CSV.read(DB_NAME, col_sep: "\t")
    database.each_with_object(Hash.new(0)) do |row, hash|
      hash[row[2]] += 1 if row[0] == "product"
    end
  end

  def count_empty_images(images_sizes)
    images_sizes.count(0)
  end
end
