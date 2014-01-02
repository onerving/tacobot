#encoding: UTF-8
require 'cgi'
require 'open-uri'
require 'nokogiri'
require 'cinch'
require 'openssl'

module Tacobot
  module Search

    class Google
    # Looks up some words on Google, returns the first result, it's link, and the search link.
      include Cinch::Plugin
      match /g (.+)/
      match /google (.+)/
  
      def search(query)
        search_url = "http://www.google.com/search?q=#{CGI.escape(query)}"
        sauce = Nokogiri::HTML(open(search_url))
        # Title of the first page - Description of the title.
        result = sauce.css("h3.r")[0].text.force_encoding("ISO-8859-1").encode("utf-8", replace: nil)
        return "No results found.", nil unless result
        result << " - #{sauce.at("span.st").text}"
        # Cut the description if it's too long and add the link.
        result = result.slice(0, 349) << "..." if result.length > 350
        result << " - #{Toolbox.shorten_url sauce.css("div.kv").children.first.text}"
        # Return that string and a second one linking to the whole search.
        return result, "Full search: #{Toolbox.shorten_url search_url}"
      end

      def execute(m, query)
        result, search_link = search(query)
        m.reply result; m.reply search_link if search_link
      end
 
    end

  
    class UrbanDictionary
    # Looks up a term in UrbanDictionary, returns the first result and the results page.
      include Cinch::Plugin
      match /ud (.+)/
      match /urban (.+)/
    
      def lookup(word)
        # We are only getting the definition, so we open in-line the Nokogiri doc and we get it from there.
        url = "http://www.urbandictionary.com/define.php?term=#{CGI.escape(word)}"
        result = CGI.unescape_html Nokogiri::HTML(open(url)).at("div.definition").text rescue nil
        # We add and return the results page if we found anything.
        if result then result << " - #{Toolbox.shorten_url(url)}" else "No results found." end
      end
    
      def execute(m, word)
        m.reply(lookup(word), false)
      end
    end


    class Steam
    # Looks up games on Steam, delivers prices and the store page.

      include Cinch::Plugin
      match /steam (.+)/
      match /game (.+)/

      def search(query)
        begin
          search_url = "http://www.steamprices.com/us/search?#{CGI.escape(query)}"
          game_price_db = "http://www.steamprices.com/#{Nokogiri::HTML(open(search_url)).css("div.box_imgdiv a")[0]["href"]}"
          game_page = Nokogiri::HTML(open(game_price_db))
        rescue 
          return "Game not found.", nil
        end

        name = game_page.css("fieldset.boxbg p.bold a")[0].text
        url =  game_page.css("fieldset.boxbg p.bold a")[0][:href]
        price = game_page.css("span.value a")[0].text rescue "free to play on Steam."
        price << " /#{game_page.css("span.value a")[1].text}" rescue ""
        price << " /#{game_page.css("span.value a")[2].text}" rescue ""
  
        return "#{name}: #{price} on Steam. ", url
      end
  
      def execute(m, query)
        game_info, game_url = search(query)
        m.reply game_info
        m.reply game_url if game_url
      end
    end

    class YouTube
    # Search on Youtube, delivers the first video it finds, who uploaded it and it's link.
      OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE # https and it's stupid shit
    
      include Cinch::Plugin
      match /yt (.+)/
      match /youtube (.+)/
      match /y (.+)/
    
      def search query, time
        # It always needs a query of what to search for, but you don't need to specify the time.
        begin
          xml = Nokogiri.HTML(open("https://gdata.youtube.com/feeds/api/videos?q=#{CGI.escape(query)}&max-results=1&fields=entry(title),entry(author(name)),entry(link)"))
        rescue
          return "YouTube is error."
        end

        # Check if we found a video about that
        link = "#{xml.css("link")[0]["href"]}" rescue nil
        return  "I didn't find a video about that." unless link 
        # If the user specified a time, put it in the video's url
        if time then link = "#{link}&t=#{time}" else link = Toolbox.shorten_url "#{link}" end
        # Return title of the video and the url.
        "#{xml.css("title").text} - #{link}"
      end
    
      def execute m, query
        # Check if the user specified a time for the video to start
        time = query.slice!(/!\d*[hms]?/).gsub!("!","") rescue nil
        m.reply search(query,time)
      end

    end

    class Wikipedia
    # Searchs in Wikipedia. That it.
      include Cinch::Plugin
      match /w (.+)/
      match /wiki (.+)/
      match /wikipedia (.+)/
    
      def search query
        wikixml = Nokogiri.HTML(open("http://en.wikipedia.org/w/api.php?action=opensearch&search=#{CGI.escape(query)}&limit=1&format=xml"))
    
        result = "#{wikixml.css("description").text} #{wikixml.css("url").text}" 
        unless result.strip.empty?; return result else "I don't know what that means." end    
      end
    
      def execute(m, query)
        m.reply(search query)
      end
    end

    class Wolfram
    # Looks up a query on Wolfram Alpha and returns the result of it.
    	include Cinch::Plugin
    	match /wa (.+)/
    	match /wolf (.+)/
    	match /wolfram (.+)/
    	match /convert (.+)/

    	def search query
        # GET YOUR OWN API KEY YOU HOBO OR ILL CUT YOU.
    		response = Nokogiri.HTML open("http://api.wolframalpha.com/v2/query?appid=42UHAX-RTXH4VAPYL&input=#{CGI.escape(query)}")
    		return "I don't know what that means." unless response.at("queryresult")["success"] == "true"
    		response.at('pod[@title="Result"] subpod plaintext').text rescue response.at('pod[@primary="true"] subpod plaintext').text

  		end
  		
  		def execute(m, query)
    		m.reply search(query)
  		end
  	end 

  	
    
  end
end