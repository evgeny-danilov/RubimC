class RubimCode::UserArray < Array
	attr_accessor :name, :type

	def []=(index, val)
		RubimCode.pout "#{@name}[#{index.to_i}] = #{val.to_s};"
	end

	def [](index)
		super index.to_i
	end

	def each
		n = LoopCounter.new
		RubimCode.pout "for (int #{n}=0; #{n}<#{self.size}; #{n}++) {"
		RubimCode.level +=1
		joy_name = self.name + "[#{n}]"
		yield(self[0].class.new("#{joy_name}"))
		RubimCode.level -=1
		RubimCode.pout "}"
	end
end 
# === END class RubimCode::UserArray ===
