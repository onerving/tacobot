require 'rubygems'
require 'cinch'

require 'open-uri'
require 'nokogiri'

class SteamSales
# Gets a "feed" of the steam sales, refreshes every 5 mins.
  
  # It just gets the "good" sales posted on r/steamdeals.
  # The database (a file, yeah) keeps it from repeating sales.
  include Cinch::Plugin


  timer 300, method: :timed
  def timed
    sdreddit = Nokogiri::HTML(open("http://www.reddit.com/r/steamdeals/new"))

    for i in 0..4
      headline = sdreddit.css("a.title")[i].text
      link = sdreddit.css("a.title")[i][:href]

      unless Toolbox.file_includes? "summer_sale_database.txt", headline
        File.open("summer_sale_database.txt", "a") do |file|
          file.puts headline
        end
        Channel("#jgallant").send "#{headline}: #{Toolbox.shorten_url(link)}"
      end
    end

  end

end


