module Pxlsrt
	class Helpers
		def self.contented(c)
			return (c.class!=NilClass and ((defined? c)!="nil") and ((/(\S)/.match("#{c}"))!=nil))
		end
		def self.red(what)
			return "\e[31m#{what}\e[0m"
		end
		def self.cyan(what)
			return "\e[36m#{what}\e[0m"
		end
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
		def self.error(what)
			puts "#{Pxlsrt::Helpers.red("pxlsrt")} #{what}"
		end
		def self.verbose(what)
			puts "#{Pxlsrt::Helpers.cyan("pxlsrt")} #{what}"
		end
	end
end