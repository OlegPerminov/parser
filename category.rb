class Category
  def initialize(category, category_level)
    @type = category_level
    @name = category.text.gsub(/[\d\t]/, "")
    @id = category['href']

    write_data
  end

  def write_data
    line = "#{@type}\t#{@name}\t-\t-\t#{@id}"
    File.open("catalog.txt", "a") { |file| file.puts line.delete("\"") }
  end
end
