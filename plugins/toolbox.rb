class Toolbox

  def self.shorten_url url
    Nokogiri::HTML(open("http://is.gd/create.php?format=simple&url=" + url)).text
  end

  def self.file_includes? filename, string
    File.open(filename, "r") do |file|
      file.each do |line|
        return true if line.include?(string)
      end
    end
    false
  end

  def self.rehost_image image_url
    "http:#{Nokogiri::HTML(open("http://imgur.com/api/upload/?url=#{image_url}")).css("div.main-image div.panel div.image a")[0]["href"]}"
    
  end
end