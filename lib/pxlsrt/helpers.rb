module Pxlsrt
	##
	# Methods not having to do with image or color manipulation.
	class Helpers
		##
		# Determines if a value has content.
		def self.contented(c)
			return (c.class!=NilClass and ((defined? c)!="nil") and ((/(\S)/.match("#{c}"))!=nil))
		end
		##
		# Used to output a red string to the terminal.
		def self.red(what)
			return "\e[31m#{what}\e[0m"
		end
		##
		# Used to output a cyan string to the terminal.
		def self.cyan(what)
			return "\e[36m#{what}\e[0m"
		end
		##
		# Checks if supplied options follow the rules.
		def self.checkOptions(options, rules)
			match=true
			for o in options.keys
				o_match=false
				if rules[o].class==Array
					if rules[o].include?(options[o])
						o_match=true
					else
						for r in 0...rules[o].length
							if rules[o][r].class==Hash
								for n in rules[o][r][:class]
									if n==options[o].class
										o_match=match
										break
									end
								end
							end
							if o_match==true
								break
							end
						end
					end
				end
				match=(match and o_match)
				if match==false
					break
				end
			end
			return match
		end
		##
		# Prints an error message.
		def self.error(what)
			puts "#{Pxlsrt::Helpers.red("pxlsrt")} #{what}"
		end
		##
		# Prints something.
		def self.verbose(what)
			puts "#{Pxlsrt::Helpers.cyan("pxlsrt")} #{what}"
		end
	end
end