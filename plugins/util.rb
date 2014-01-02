require 'cgi'
require 'open-uri'
require 'open_uri_redirections'
require 'nokogiri'
require 'cinch'
require 'json'
require 'openssl'

module Tacobot
  module Util

  	class Help
  	  include Cinch::Plugin
  	  match /help/

  	  def execute(m)
  	  	menu = "."
  	  	m.reply m.to_s
  	  end

  	end

    class RandomListener
      include Cinch::Plugin
      listen_to :channel

      def listen(m)
        m.reply "fuck Tiy" if m.message.include? "tiy"
        m.reply "starbound is fun" if m.message.include? "starbound"
      end

    end

    # class ServerInfo
    #   include Cinch::Plugin
    #   match /serverinfo/
    #   match /server/
    #   match /status (.+)/, method: :status
    #   match /updateinfo (:+)/, method: :update



    # end

    class Offender
      # Throws a random insult to someone.

      include Cinch::Plugin
      match /insult (.+)/

      def execute(m, target)
        part1 = ["lazy", "stupid", "insecure", 
        "idiotic", "slimy", "slutty", "smelly",
        "pompous", "communist", "dicknose",
        "pie-eating", "racist", "elitist",
        "white trash", "drug-loving", "butterface",
        "tone deaf", "ugly", "creepy"].sample

        part2  = ["douche", "ass", "turd", "rectum",
        "butt", "cock", "shit", "bitch", "crotch",
        "bitch", "turd", "prick", "slut", "taint",
        "fuck", "dick", "boner", "shart", "nut",
        "sphincter"].sample

        part3 = ["pilot", "canoe", "captain", "pirate",
        "hammer", "knob", "box", "jockey", "nazi",
        "waffle", "goblin", "blossum", "biscuit", "clown",
        "socket","monster", "hound", "dragon", "balloon"].sample

        joint = if part1.start_with?("a", "e", "i", "o", "u") then "an" else "a" end

        m.reply "#{target}: you are #{joint} #{part1} #{part2} #{part3}" unless target == "onerving" or target == "Onerving" or target == "irving"
      end
      end

      class EightBall
      # Welp.

      include Cinch::Plugin
      match /8ball (.+)/

      def execute(m, target)
        m.reply ["It is certain", "It is decidedly so", 
          "Yes, definitely", "You may rely on it", 
          "As I see it, yes", "Most likely", 
          "Outlook good", "Yes", "Signs point to yes",
          "Reply hazy try again", "Ask again later",
          "Better not to tell you now",
          "Concentrate and ask again", "Don't count on it",
          "My reply is no", "My sources say no",
          "Outlook not so good", "Very doubtful"].sample     
      end
      end
    


  	class IsUp
			# Check if a page is down for everyone or just you.

  		include Cinch::Plugin
  		match /isup (.+)/

		  def check_if_up(url)
		    status = Nokogiri::HTML(open("http://www.isup.me/#{CGI.escape(url)}")).at("div#container")
		    check = ""
		    for i in 0..2 do check << status.children.to_a[i].text end
		    check.strip
		  end

		  def execute(m, query)
		    m.reply check_if_up(query)
		  end
		
		end
  	
  	class URLParser
		# Returns info about urls posted in the channel.
  		include Cinch::Plugin
  		OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

  		listen_to :channel

  		def listen(m)
        # Check all the urls that a message contains.
    	  urls = URI.extract(m.message, ["http", "https"]).map
    	  urls.each do |url|
    	  	# Check if the link doesn't 404.
          begin
            link  = URI.parse(url)
            # Allow redirections is so it can open https sites that redirect always
            # for no good reason, like Soundcloud; it takes a fuckton of time to open it, though.
            sauce = Nokogiri::HTML open(link, :allow_redirections => :all)
          rescue
        		m.reply "That page is error."; next
      		end

    			# Handler for different kind of links, to give better a better description about the site.
      		case link.host

        		when "www.youtube.com", "youtube.com"
              if url.include?("watch") 
                m.reply "YouTube >> #{sauce.css("span.watch-title").text.strip}"
              else m.reply sauce.title end

            when "www.reddit.com", "reddit.com"
							unless url.include? ".com/r/" then m.reply sauce.title.strip; return ; end

         			if url.include? ".com/r/"
          			if url.include? "/comments/"
          				title = sauce.title.strip.gsub(/:.*/, "")
          				author = sauce.css("p.tagline a.author").first.text
	
	          			m.reply "Reddit: \"#{title}\" submitted by #{author}."
	          			return
	          		end

             		jason = Nokogiri::HTML(open("#{url}/about.json")).text
             		begin
         					info = JSON.parse(jason, :max_nesting => 100)
         				rescue
         					m.reply "That doesn't appear to be a valid subreddit."; return
         				end
            		desc = info["data"]["public_description"].gsub(/\[\*?|\*?\]|\(.*?\)/, "")

            		unless desc.empty? then m.reply desc else m.reply "No subreddit description available." end

							else
								m.reply sauce.title
            	end
	
	        	when "www.twitch.tv", "twitch.tv"
	          	user = sauce.css("a.channel_name").first.text rescue ""
	          	unless (game = sauce.css("a.js-game").text) == "/directory/game/" then stream_info = "#{user} streaming #{game}" else stream_info = "#{user} stream" end
							
							stream_title = "#{sauce.css("span.js-title").text}"
          		m.reply "Twitch.tv: #{stream_title}" unless user.downcase == stream_title.downcase
          		m.reply stream_info

            when "images.4chan.org"
              m.reply "Don't hotlink from 4chan you fag: #{Toolbox.rehost_image(url)}"
            when "static.fjcdn.com"
              m.reply "Don't hotlink from FunnyJunk you fag: #{Toolbox.rehost_image(url)}"

        		else
          		m.reply sauce.title.strip
          end
        end

      end
    end

    class DiceRoll
      # In the format dn, where n can be any real number greater than 1
      # It can also do a coin flip returning the result in a legible way.
      include Cinch::Plugin
      match /d(\d+)/
      match /coin/, method: :coin

      def execute(m, number)
        m.reply "#{1 + Random.rand(number.to_i)}"
      end

      def coin(m) 
        if Random.rand(2) == 1 then m.reply "Heads" else m.reply "Tails" end 
      end

    end
  end
end