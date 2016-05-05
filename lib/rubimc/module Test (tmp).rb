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

