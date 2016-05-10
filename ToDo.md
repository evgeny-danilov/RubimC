List of small tasks:
0. Set private and protected methods for all RubimCode 
1. realise logical operations: write tests
2. preprocessor: for correct priority of logical operators wrap all 'not' operators: "!true" => "(!true)"; "not false" => "(not false)"
3. Test core with command "rubimc test"
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