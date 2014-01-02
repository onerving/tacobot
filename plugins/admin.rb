require 'cinch'

module Tacobot 
  module Admin

  	class Auth
  		class << self; attr_accessor :admins end
  		@admins = File.read("admins.txt").split(",").map(&:strip)

  		def self.auth_user? user
  			user.refresh
	  	  @admins.include?(user.authname)
  		end

  		def self.add_admin authname
  			return "#{authname} is already an Admin." if @admins.include?(authname)
  			if authname then @admins.push(authname); save; "#{authname} is now an Admin." end
  		end

  		def self.remove_admin authname
  			return "Bitch please." if authname == "Onerving"
  			@admins.delete(authname){ return "Admin not found." }
  			save; "#{authname} is no longer an Admin"
  		end
  		
  		def self.save
  			 File.open("admins.txt", 'w') { |file| 
  			 	file.truncate(0)
  			 	file.write("#{@admins.join(",")}")
  			 }
  		end

  		def self.admin_list
  			@admins.join(", ")
  		end

  	end


  	class JoinPart
  	# Manages the bot joining and parting channels via a command.
	  	include Cinch::Plugin
	  	match /join (.+)/     , method: :join
	  	match /part(?: (.+))?/, method: :part
	
	
	  	def join(m, channel)
	    	return unless Auth.auth_user? m.user
	    	Channel(channel).join
	  	end
	
	  	def part(m, channel)
	    	return unless Auth.auth_user? m.user
	    	channel ||= m.channel
	    	Channel(channel).part
	  	end
		end


		class AutoRejoin
		# A really dumb hack but it works so whatever.
    # It tries to rejoin a channel whenever someone is kicked.
			include Cinch::Plugin
	
			listen_to :kick
	
			def listen(m)
				Channel(m.channel).join
	  	end

		end


		class ChangeNick
			# Makes the bot change it's nick.
			include Cinch::Plugin
			match /nick (.+)/, method: :change_nick

			def change_nick(m, new_nick)
				return unless Auth.auth_user? m.user
				bot.nick = new_nick
			end

		end


		class ManageAdmins
			# Admin aboos and stuff
			include Cinch::Plugin
			match /op (.+)/, method: :op
			match /deop (.+)/, method: :deop
			match /admins\?/, method: :list

			def op(m, authname)
				if Auth.auth_user? m.user
					m.reply Auth.add_admin(authname)
				else
					m.reply "You're not authorized to do that."
				end

			end

			def deop(m, authname)
				if Auth.auth_user? m.user
					m.reply Auth.remove_admin(authname)
				else
					m.reply "You're not authorized to do that."
				end
			end

			def list(m)
				m.reply Auth.admin_list
			end

		end


		class ManageVoice
			# 2lazy
			include Cinch::Plugin
	
			listen_to :kick
			
		end

    class Parrot
      include Cinch::Plugin
      match /m (\S*) (.+)/

      def execute(m, channel, message)
        if Auth.auth_user? m.user
          Channel(channel).send message
        else
          m.reply "You're not authorized to do that."
        end
        
      end
    end


  end
end