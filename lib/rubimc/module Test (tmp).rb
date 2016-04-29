#############################################
# Замена объявления пользовательских классов
#############################################
module Test
    class RubimClass
        # protected: #add methods, available only in RubimClass (not in child classes)
        def self.pout_in_h # вывод объявлений классов в h-файлы
            # ToDo ...
        end

        def self.new_userclass= (anonym_class)
            class_name, class_body = anonym_class
            Test.const_set(class_name, class_body)
            # ToDo: set pout destination in default
        end
    end


RubimClass.pout_in_h; RubimClass.new_userclass = "Joystick", Class.new(RubimClass) do
# class Joystick
    attr_accessor :num
    def getADC
        puts @num
    end
end

jj = Joystick.new; jj.num = 456; jj.getADC

end # Test module


##################################
# Замена ключевого слова IF
##################################
def __rubim__ifmod (cond); "if #{cond} {"; true; end
def __rubim__if(cond); pout "if( #{cond}) {"; yield; pout "}" end
def __rubim__elsif(cond); pout "} else if (#{cond}) {"; end
def __rubim__else(); pout "} else {"; end
def __rubim__block; pout "{"; yield; pout "}"; end

# preprocessor (old)
# замена "if" на "__rubim__if" => в случае если перед "if" только символы с начала строки /(\n\s?)if(\ .*\n)/ = '\1__rubim__if \2'
# замена "if" на "__rubim__if" => в случае если перед "if" символ "="
# замена "if" на "if __rubim__ifmod(" => в случае если перед "if" выражение, но нет "=" непосредственно перед "if"
#   и вставка "); __rubim__end" в конце строки

#####################################################
# Замена ключевого слова IF (модиф. версия)
#   (ex: puts "true" if i>5)
#####################################################
require 'ripper'
class RipperPreprocessor

    # ToDo: установить приватные и публичные методы

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
    # Example find_rec =>
    #   parse_array = Ripper.sexp("puts 'qwe' if i>0 and true")
    #   result = find_rec(parse_array, :@int)
    #   result.each {|res| p res}

    # Поиск позиции наиболее близкого идентификатора справа
    def self.find_near_pos(array)
        array.each do |el|
            if el.is_a? Array
                if (el[0].is_a? Symbol and el.size==3 and /\A@/===el[0].to_s)
                    return el[2]
                else
                    res = find_near_pos(el)
                    return res unless res.nil?
                end
            end
        end
        return false
    end

    # Поиск ключевого слова "if" начиная с позиции near_pos и левее
    def self.find_ifmod_pos(source, near_pos)
        lineno, charno = near_pos
        curline = source.lines[lineno]

        charno.downto(0) do |index|
            return [lineno, index] if /\ if\ / === curline[index-1..-1]
        end

    end

    # Замена ключевого слова "if" (публичный метод)
    def self.replace_ifmod
        source = "puts 'qwe' if (i>0 and true)"
        parse_array = Ripper.sexp(source)
        result = find_rec(parse_array, :if_mod)
        
        result.reverse.each do |res|
            # 1. find if_mod next statement
            near_pos = find_near_pos(res)

            # 2. find previous "if" keyword (with Ripper.lex) in cur line
            ifmod_pos = find_ifmod_pos(source, near_pos)

            # 3. replace "if" to "__rubim__ifmod"
            source = replace_words(source, "if", "__rubim__ifmod(", ifmod_pos)

            # 4. ToDo: paste "; __rubim__end" at the end of cur line
        end
    end
end

#####################################
# Замена ключевого слова IF
#####################################
require "ripper"
class RipperPreprocessor
    str = " if true then
                puts \"qwe\"
            else
               puts \"ewq\"
            end
            "

    def self.replace_words(source, dstr, rstr, pos)
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

    def self.replace_if_kw
        test = Ripper.lex(str)
        test.each do |r| 
            if r[1] == :on_kw and r[2] == "if"
                str = replace_words(str, r[2], "__rubim__if", r[0])
            end
        end

        test = Ripper.lex(str)
        test.each do |r| 
            if r[1] == :on_kw and r[2] == "then"
                str = replace_words(str, r[2], ";", r[0]) # ToDo: replace only in "if" statement ??? (check all ruby statements if/while/until/case)
            end
        end
    end

    puts str
end


##############################################
# Замена ключевого слова END (в "if" группе)
##############################################
require "ripper"
class RipperPreprocessor

    def self.find_end_statement(lex_array, pos_in_array)
        index = pos_in_array+1
        while index < lex_array.size do
            
            pos, ident, symb = lex_array[index]
            if ident == :on_kw and /while|for|if/ === symb
                index = find_end_statement(lex_array, index)
            elsif ident == :on_kw and symb == "end"
                return index
            end
            
            index += 1
        end
    end


    str = "puts 'a'; i=1
            if i>0
                puts 'w'
            else
                while (false)
                    puts 'e'
                end
            end
            "
    def self.replace_end_kw
        lexs = Ripper.lex(str)
        lexs.each_with_index do |lex, index|
            pos, ident, symb = lex
            if ident == :on_kw and symb == "if"
                # 1. replace "if"
                # ToDo...replace and update 'lexs' array
                
                # 2. find "end" statement of finding "if"
                end_index = find_end_statement(lexs, index)
                end_pos = lexs[end_index][0]

                # 3. replace "end"
                str = replace_words(str, "end", "__rubim__end", end_pos)
                puts str
                break
            end
        end

end


# ToDo: Add test
# 
# Прим.: не забыть про замену __rubim__tmpif на if

# ==Test #2a (if statement):
# input = "if tmp_cond [then]
#               puts 'qwe'
#           elsif tmp_cond2 [then]
#               puts 'ewq'
#           else
#               puts 'ewq'
#           end"
# output = "__rubim__if tmp_cond; __rubim__block do
#               puts 'qwe'          
#           __rubim__elsif tmp_cond2 [then]
#               puts 'ewq'
#           __rubim__else           
#               puts 'ewq'          
#           end"
# 
# ==Test #3a (while/until statement):
# input = "while tmp_cond [do]
#               puts 'qwe'
#           end"
# output = "__rubim__while tmp_cond; __rubim__block do
#               puts 'qwe'          
#           end"
# 
# ==Test #4a (modify while/until):
# input = "begin
#               puts 'qwe'
#           end while tmp_cond"
# output = "__rubim__block do
#               puts 'qwe'
#           end __rubim__tmpif __rubim__modwhile tmp_cond"
# 
# == Test #5a (unless modify)
# input = ""
# output = ""

# == Test #5b (unless statement)
# input = ""
# output = ""