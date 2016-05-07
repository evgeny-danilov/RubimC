=begin

ЗАДАЧА ПРЕПРОЦЕССОРА:
	1. (готово) замена оператора присваивания: "=" на ".c_assign="
	2. (готово )замена всех цифр(целые, дробные, отриц.)
	3a. (не готово) Замена условий (find_far_pos - возвращать позицию с учетом длины идентификатора)
	3b. (готово) Замена циклов
	3c. Замена управляющих структур: break, next, redo, retry
	4. замена строк "123" => UserVariable.new("123")
		- строки "это_строка" и 'это_строка'
	5. Поиск необъявленных переменных и выдача ошибок
	6. Предупреждение об использовании зарезервированных переменных и методов
		все  они начинаются на "__rubim__"
		(напр. __rubim__times или __rubim__classparams)
	7. Предупреждение об использовании зарезервированных классов
		UserClass, UserArray (лучше заменить на RubimClass, RubimArray)
	8. Добавление предка к пользовательским классам
	9. Замена return на __rubim_return
	10. Сохранить все пользовательские комментарии в генерируемом коде
	11. Цикл for - хз-чо делать...


=end

class Object
	def in?(array)
		array.each {|x| return true if x == self}
		return false
	end
end

require 'ripper'
class RubimRipper
	# 1. (готово) замена оператора присваивания: "=" на ".c_assign="
    def self.replace_assing_operators(source)
    	lexs = Ripper.lex(source)
    	lexs.reverse_each do |lex|
            pos, ident, symb = lex
            if (ident == :on_op and symb == "=")
            	source = replace_words(source, symb, ".c_assign=", pos)
            end
    	end
    	return source
    end

	# 2. (готово )замена всех цифр(целые, дробные, отриц.)
    def self.replace_all_numeric(source)
    	lexs = Ripper.lex(source)
    	lexs.reverse_each do |lex|
            pos, ident, symb = lex
            if (ident.in? [:on_int, :on_float])
            	bug_plus = (symb[0]=="+" ? "+" : "")
            	# Note: space before "UserVariable" is neсessary
            	source = replace_words(source, symb, "#{bug_plus} RubimCode::UserVariable.new(#{symb}, 'fixed')", pos)
            end
    	end
    	return source
    end

    def self.replace_modify_express(source, kw_str = "if")
		kw_sym = "#{kw_str}_mod".to_sym

        parse_array = Ripper.sexp(source)
        mod_expresses = find_rec(parse_array, kw_sym)
        
        mod_expresses.reverse_each do |record|
            kw_pos = find_keyword_pos(source, record, kw_str) # 1. find modify 'if/unless' keywords
            cond_pos = find_express_end(source, record[1]) # 2. find end of 'if/unless' condition

            case kw_str
				when "if"
					source = paste_before_pos(source, "; RubimCode.rubim_end;", cond_pos) # 3. paste "rubim_end" at the end of condition
					source = replace_words(source, kw_str, ";RubimCode.rubim_tmpif RubimCode.rubim_ifmod", kw_pos) # 4. replace "if/unless" keywords to "rubim_ifmod/__rubim_unlessmod"
				when "unless"
					source = paste_before_pos(source, "; RubimCode.rubim_end;", cond_pos) # 3. paste "rubim_end" at the end of condition
					source = replace_words(source, kw_str, ";RubimCode.rubim_tmpif RubimCode.rubim_unlessmod", kw_pos) # 4. replace "if/unless" keywords to "rubim_ifmod/__rubim_unlessmod"
				when "while"
					source = replace_words(source, kw_str, ";RubimCode.rubim_tmpif RubimCode.rubim_begin; RubimCode.rubim_whilemod", kw_pos) # 4. replace "while/until" keywords
				when "until"
					source = replace_words(source, kw_str, ";RubimCode.rubim_tmpif RubimCode.rubim_begin; RubimCode.rubim_untilmod", kw_pos) # 4. replace "while/until" keywords
	        end
        end
        return source
    end

    def self.replace_flat_express(source, kw_str = "if")
    	source = replace_keywords(source, "then", ";")
		kw_sym = "#{kw_str}".to_sym

        parse_array = Ripper.sexp(source)
        flat_expresses = find_rec(parse_array, kw_sym)
        
        flat_expresses.reverse_each do |record|
            kw_pos = find_keyword_pos(source, record, kw_str) # 1. find modify 'if/unless' keywords
            cond_pos = find_express_end(source, record[1]) # 2. find end of 'if/unless' condition

			lineno, charno = cond_pos
			if (source.lines[lineno-1][charno..charno+1] != "do")
				source = paste_before_pos(source, " do", cond_pos) # 4. paste "str" at the end of condition
	        end
			source = replace_words(source, kw_str, "RubimCode.rubim_#{kw_str}", kw_pos) 
        end

        return source
    end

    def self.replace_loop(source)
		lexs = Ripper.lex(source)
		lexs.reverse_each do |lex|
			kw_pos, ident, symb = lex
			if (ident == :on_ident and symb == "loop")
				source = replace_words(source, symb, "RubimCode.rubim_loop", kw_pos)
		    end
		end
		return source
    end

    def self.replace_then_else_elsif_kw(source)
    	source = replace_keywords(source, "then", ";")
    	source = replace_keywords(source, "else", "RubimCode.rubim_else")
    	source = replace_keywords(source, "elsif", "RubimCode.rubim_elsif")
    	return source
    end

    def self.replace_rubim_tmpif(source)
    	source.gsub(/;RubimCode.rubim_tmpif/, 'if')
    end

    def self.replace_boolean_kw(source)
    	source = replace_keywords(source, "true", "RubimCode::UserVariable.new(true, 'fixed')")
    	source = replace_keywords(source, "false", "RubimCode::UserVariable.new(false, 'fixed')")
    	return source
    end

    def self.add_binding_to_init(source) # for initialize variables with methods 'integer', 'float', e.t.
		sexp = Ripper.sexp(source)
		command_array = find_rec(sexp, :command)
		command_array.reverse_each do |elem|
			varies_name = []
			symb, helper_name, helper_pos = elem[1]
			if helper_name.in? ["boolean", "bool", "integer", "int", "float", "double","string"] # if one of helper methods
				args_add_block = find_rec(elem, :args_add_block)[0][1]
				args_add_block.each do |arg|
					if arg[0] == :symbol_literal
						tmp_res = []
						tmp_res << find_rec(arg, :@ident)[0]
						tmp_res << find_rec(arg, :@ivar)[0]
						tmp_res << find_rec(arg, :@gvar)[0]
						varies_name << tmp_res.compact.map {|el| el[1]}
					elsif arg[0] == :bare_assoc_hash
						bare_array = find_rec(arg, :@label)
						bare_array.each do |bare|
							varies_name << bare[1][0..-2]
						end
						break
					else
						raise ArgumentError.new("Wrong arguments for helper '#{helper_name}'") 
					end
				end
				var_str = varies_name.join(', ') # list of vars, defined in helper method
				source = paste_before_pos(source, "#{var_str} = ", helper_pos) # paste vars before helper method
			end
		end
		return source
    end

	#########################
    # === PRIVATE SECTION ===
    #########################
    private
	    # Поиск вложенного массива (sexp) с ключевым символом find_sym (рекурсивный вызов)
	    def self.find_rec(array, find_sym)
	        return [] unless array.is_a? Array
	        result = []
	        array.each do |elem| 
	            result << array if elem == find_sym
	            result += find_rec(elem, find_sym)
	        end
	        return result
	    end

	    # Замена слов
	    def self.replace_words(source, dstr, rstr, pos) # источник, исходное слово, конечное слово, начальная позиция
	        output = ""
	        lineno, charno = pos
	        source.lines.each_with_index do |line, index| 
	            if index == lineno-1
	                line[charno .. charno+dstr.length-1] = rstr
	            end
	            output += line
	        end
	        return output
	    end

	    # Вставка слова до указанной позиции
	    def self.paste_before_pos(source, rstr, pos)
	        output = ""
	        lineno, charno = pos
	        source.lines.each_with_index do |line, index| 
	            if index == lineno-1
	                line.insert(charno, rstr)
	            end
	            output += line
	        end
	        return output
	    end

		# Замена ключевых слов
	    def self.replace_keywords(source, kw, repl_kw)
	    	lexs = Ripper.lex(source)
	    	lexs.reverse_each do |lex|
	            kw_pos, ident, symb = lex
	            if (ident == :on_kw and symb == kw)
	            	source = replace_words(source, symb, repl_kw, kw_pos)
	            end
	    	end
	    	return source
	    end

	    # Поиск позиции наиболее близкого идентификатора справа
	    def self.find_near_pos(array)
	        array.each do |el|
	            if el.is_a? Array # если найден идентификатор, указывающий на позицию 
	                if (el[0].is_a? Symbol and el.size==3 and /\A@/===el[0].to_s)
	                    return el[2]
	                else
	                    res = find_near_pos(el)
	                    return res unless res.nil?
	                end
	            end
	        end
	        raise "can not find near position in array #{array}"
	    end

	    # Поиск позиции наиболее дальнего идентификатора справа (рекурсивно)
	    def self.find_far_pos(array)
	        array.reverse_each do |el|
	            if el.is_a? Array # если найден идентификатор, указывающий на позицию
	                if (el[0].is_a? Symbol and el.size==3 and /\A@/===el[0].to_s)
	                    return el[2]
	                else
	                    res = find_far_pos(el)
	                    return res unless res.nil?
	                end
	            end
	        end
	        raise "can not find far position in array #{array}"
	    end

	    # Поиск ключевого слова "kw_str" начиная с позиции near_pos и левее
	    def self.find_keyword_pos(source, array, kw_str)
	    	near_pos = find_near_pos(array)
	        lineno, charno = near_pos
	        curline = source.lines[lineno-1]
	        charno.downto(0) do |index|
	            return [lineno, index-1] if /#{kw_str} / === curline[index-1..-1]
	        end
	    	raise "can not find keyword '#{kw_str}' if array #{array}"
	    end

	    # Поиск окончания выражения
	    def self.find_express_end(source, express_array)
	    	start_pos = find_far_pos(express_array)
	        lineno, charno = start_pos
	    	lexs = Ripper.lex(source)
	    	lexs.each do |lex|
	            lex_pos, ident, symb = lex
	    		if ((lex_pos <=> start_pos) >= 0) then
		    		if ((ident==:on_nl && symb=="\n") or
		    			(ident==:on_semicolon && symb==";") or
		    			(ident==:on_kw && symb=="do") or
		    			(ident==:on_kw && symb=="end")) then
			    			return lex_pos
		    		end
	    		end
	    	end
	    	lcount = source.lines.count
	    	return [lcount, source.lines[lcount-1].length]
	    end

end # class RubimRipper

class PreProcessor
	@@program = ""

	def self.program; @@program; end
	def self.program=(str); @@program = str; end

	def self.execute(str)
		@@program = str
		@@program = RubimRipper.replace_assing_operators(@@program)
		@@program = RubimRipper.replace_all_numeric(@@program)

		# Последовательность очень важна - не нарушать!
		@@program = RubimRipper.replace_then_else_elsif_kw(@@program)

		@@program = RubimRipper.replace_modify_express(@@program, "if")
		@@program = RubimRipper.replace_modify_express(@@program, "unless")
		@@program = RubimRipper.replace_modify_express(@@program, "while")
		@@program = RubimRipper.replace_modify_express(@@program, "until")

		@@program = RubimRipper.replace_flat_express(@@program, "if")
		@@program = RubimRipper.replace_flat_express(@@program, "unless")
		@@program = RubimRipper.replace_flat_express(@@program, "while")
		@@program = RubimRipper.replace_flat_express(@@program, "until")

		@@program = RubimRipper.replace_loop(@@program)
		@@program = RubimRipper.replace_rubim_tmpif(@@program)

		@@program = RubimRipper.add_binding_to_init(@@program)

		@@program = RubimRipper.replace_boolean_kw(@@program)


		# See 
		#  p defined?(x = 1) # => "assignment"
		#  p defined?(x[5] = 1) # => "method"
		#  p defined?(x[5] += 1) # => "method"

		# --- OLD VERSION, BASED ON REGEXP ---
		# убрать пробелы между всеми односимвольными операторами (кроме оператора ":")
		# operators = "\\+\\-\\*\\/\\^\\!\\=\\~\\?\\:\\%\\|\\&"
		# @@program.gsub!(/\ *?([#{operators}&&[^\:]])\ ?/, '\1')

		# замена оператора "=" на ".c_assign=" (только перед переменными)
		# ch = "a-zA-Z"
		# @@program.gsub!(/(^|[^#{ch}\.])([#{ch}\d]+)=([^\=\~])/, '\1\2.c_assign=\3')

		# замена всех цифр(Fixnum), после которых идут операторы, на UserVariable.new()
		# @@program.gsub!(/(^|[^\w])([-+]?\d*\.?\d+)([#{operators}&&[^\=]])/, '\1UserVariable.new(\2)\3')
		# замена всех цифр(Fixnum), после которых идет указание метода, на UserVariable.new()
		# @@program.gsub!(/(^|[^\w])(\d+)(\.[\w&&[^\d]])/, '\1UserVariable.new(\2)\3')
	end 


	# write preprocessing program in file
	def self.write_in_file(input_file, dirname, basename, outfile)
		# basename = File.basename(input_file)
		# dirname = File.dirname(input_file)
		# outfile = "#{dirname}/release"

		# # clear directory "release"
		# Dir.mkdir(outfile) unless Dir.exists?(outfile)
		# Dir.foreach(outfile) do |file| 
		# 	File.delete("#{outfile}/#{file}") if (file!='.' && file!='..')
		# end
		
		PreProcessor.execute( File.read(input_file) )
		File.write("#{outfile}", PreProcessor.program)

		print "done\n"
	end

end
