List of small tasks:
1. support float and bool C-types (and write tests)
1. realize rubim_next and rubimc_break (and write tests)
1. check scope of variables in interrupts (see example "ex1_avr_tiny13.rb")
2. output/input - init vars like in method :integer
1. Test core with command "rubimc test"
5. Реализация пользовательских методов def()
6. __rubim__rval#{level}- добавить название метода: 
    __rubim__#{method}rval#{level}
7. описать зарезервивованные слова: 
    + имена классов: RubimCode, Controllers, AVRController, PIC8Controller, STM8Controller, 
    + переменные и методы начинающиеся на __rubim__... 
    + методы [integer, float, string, bool], [int8, u_int8, ...], 
    + метод print_comment
    + методы input, output
8. init arrays