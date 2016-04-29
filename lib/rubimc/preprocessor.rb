=begin

ЗАДАЧА ВАЛИДАТОРА:
	1. Проверить(тупо исполнить) весь код на соответствие лексике Руби 
		- тупо нельзя - если есть, например, бесконечные циклы циклы
		- лучше использовать https://github.com/YorickPeterse/ruby-lint

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
            	source = replace_words(source, symb, "#{bug_plus} RubimCode::UserVariable.new(#{symb})", pos)
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
    	source = replace_keywords(source, "true", "UserVariable.new(true)")
    	source = replace_keywords(source, "false", "UserVariable.new(false)")
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
	    def self.replace_words(source, dstr, rstr, pos) # источник, исход. слово, конечное слово, начальная позиция
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

	    # Поиск позиции наиболее дальнего идентификатора справа
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
	    		# if ((lex_pos[0] >= start_pos[0]) and (lex_pos[1] >= start_pos[1])) then
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
	@@programm = ""

	def self.programm; @@programm; end
	def self.programm=(str); @@programm = str; end

	def self.execute(str)
		@@programm = str
		@@programm = RubimRipper.replace_assing_operators(@@programm)
		@@programm = RubimRipper.replace_all_numeric(@@programm)

		# Последовательность очень важна - не нарушать!
		@@programm = RubimRipper.replace_then_else_elsif_kw(@@programm)

		@@programm = RubimRipper.replace_modify_express(@@programm, "if")
		@@programm = RubimRipper.replace_modify_express(@@programm, "unless")
		@@programm = RubimRipper.replace_modify_express(@@programm, "while")
		@@programm = RubimRipper.replace_modify_express(@@programm, "until")

		@@programm = RubimRipper.replace_flat_express(@@programm, "if")
		@@programm = RubimRipper.replace_flat_express(@@programm, "unless")
		@@programm = RubimRipper.replace_flat_express(@@programm, "while")
		@@programm = RubimRipper.replace_flat_express(@@programm, "until")

		@@programm = RubimRipper.replace_loop(@@programm)
		@@programm = RubimRipper.replace_rubim_tmpif(@@programm)

		# @@programm = RubimRipper.replace_boolean_kw(@@programm)


		# See 
		#  p defined?(x = 1) # => "assignment"
		#  p defined?(x[5] = 1) # => "method"
		#  p defined?(x[5] += 1) # => "method"

		# --- OLD VERSION, BASED ON REGEXP ---
		# убрать пробелы между всеми односимвольными операторами (кроме оператора ":")
		# operators = "\\+\\-\\*\\/\\^\\!\\=\\~\\?\\:\\%\\|\\&"
		# @@programm.gsub!(/\ *?([#{operators}&&[^\:]])\ ?/, '\1')

		# замена оператора "=" на ".c_assign=" (только перед переменными)
		# ch = "a-zA-Z"
		# @@programm.gsub!(/(^|[^#{ch}\.])([#{ch}\d]+)=([^\=\~])/, '\1\2.c_assign=\3')

		# замена всех цифр(Fixnum), после которых идут операторы, на UserVariable.new()
		# @@programm.gsub!(/(^|[^\w])([-+]?\d*\.?\d+)([#{operators}&&[^\=]])/, '\1UserVariable.new(\2)\3')
		# замена всех цифр(Fixnum), после которых идет указание метода, на UserVariable.new()
		# @@programm.gsub!(/(^|[^\w])(\d+)(\.[\w&&[^\d]])/, '\1UserVariable.new(\2)\3')
	end 

end

# write preprocessing programm in file
unless defined? TEST_MODE 
	input_file = ARGV[0]
	if input_file.nil?
	 	puts "ERROR: Input file in params is not defined"
	 	exit
	end

	unless File.exist?(input_file)
	 	puts "ERROR: File #{input_file} not found"
	 	exit
	end

	print "start preprocessor..."
	file_name = input_file.split('/')[-1]
	file_path = input_file.split('/')[0..-2].join('/')
	release_path = "#{file_path}/release"
	release_path[0] = '' if release_path[0] == '/'

	# clear directory "release"
	Dir.mkdir(release_path) unless Dir.exists?(release_path)
	Dir.foreach(release_path) do |file| 
		File.delete("#{release_path}/#{file}") if (file!='.' && file!='..')
	end
	
	pre_file = "#{release_path}/#{file_name}"
	PreProcessor.execute( File.read(ARGV[0]) )
	File.write(pre_file, PreProcessor.programm)

	print "done\n"
end
