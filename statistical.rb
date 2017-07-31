require 'csv'

module Statistical
  IMG_FOLDER = "./images"
  DB_NAME = "catalog.txt"

  def print_statistics
    return if single_category?
    print_img_statistic
    print_product_statistic
    exit!
  end

  private

  def print_img_statistic
    content = Dir[IMG_FOLDER + "/*"]

    avg_size = File.size(IMG_FOLDER).to_f / content.size
    min_size = content.map { |file| File.size(file) }.min
    max_size = content.map { |file| File.size(file) }.max

    puts "Images parameters:"
    puts "Average image size: #{(avg_size * 1000).to_i} B"
    puts "Minimum image size: #{min_size} B"
    puts "Maximum image size: #{max_size} B"

    puts "\nPercent of products which has image is " \
         "#{((1 - count_empty_images.to_f / content.size) * 100).round(2)}%"
  end

  def single_category?
    count_products.size == 1
  end

  def print_product_statistic
    products = count_products
    total = products.values.inject(0, :+)
    puts "\nProducts statistics:"
    products.each do |category, product_quantity|
      puts "Category: #{category} contains #{product_quantity} products. " \
           "It's a #{(product_quantity.to_f / total * 100).round(2)}% of total."
    end
  end

  def count_products
    database = CSV.read(DB_NAME, col_sep: "\t")
    database.each_with_object(Hash.new(0)) do |line, hash|
      hash[line[2]] += 1 if line[0] == "product"
    end
  end

  def count_empty_images
    content = Dir[IMG_FOLDER + "/*"]
    content.map! { |file| File.size(file) }
    content.count(0)
  end
end
