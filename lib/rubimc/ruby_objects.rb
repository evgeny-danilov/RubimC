#####################################################################
# Modify Ruby standard libraries
#####################################################################

class Object
	def not_nil?
		!self.nil?
	end

	def has_parent?(name)
		return false unless self.respond_to? :ancestors
		self!=name and self.ancestors.include?(name)
	end

	def to_rubim
		type = case self.class.name
					when "Fixnum" then 'int'
					when "Float" then 'float'
					when "String" then 'string'
					else nil
				end
		if type.nil? or self.to_s.nil?
			RubimCode.perror "Неизвестный тип переменной"
		end
		UserVariable.new(self.to_s, type)
	end

	def in?(array)
		array.each {|el| return true if el == self}
		return false
	end

end

class Class
	# get list of all childs inhereted from self class
	def descendants
		ObjectSpace.each_object(Class).select { |klass| klass < self }
	end # see alternative realization: http://apidock.com/rails/Class/descendants
end

class Hash
	def permit_and_default! (**args)
		self.keys.each do |param|
			if not args.keys.include? param
			    mname = caller_locations(1)[2].label
			    perror "Method '#{mname}' have no param: #{param}}" 
			end
		end

        args.keys.each do |param|
		    self[param] = args[param] if self[param].nil?
        end

	end
end


