#####################################################################
# TEST RUBIM Core
#####################################################################
class TestController < Controllers; end

RSpec.describe TestController do
	before :each do
		RubimCode.level = 1
		$before_input = ''
		$outstr = ''
		$test_mcu = TestController.new
	end

	it 'init integer' do
		input_set("integer :viar")
		expect($outstr).to eq("int viar;")
	end

	it 'init integer with defult value' do
		# input_set("integer viar2: 4.7")
		# ToDo
	end

	it 'init float' do
		input_set("float :viar")
		expect($outstr).to eq("float viar;")
	end

	it 'init boolean' do
		input_set("boolean :viar")
		expect($outstr).to eq("bool viar;")
	end

	it 'assign integer with expression' do
		before_input("integer :b, :c, :u1")
		input_set("u1 = b + c * b + b")
		expect($outstr).to eq("u1 = (b+(c*(b))+(b));")

		input_set("u1 = b + c - b / b")
		expect($outstr).to eq("u1 = (b+(c)-(b/(b)));")
	end

	it 'init array' do
		input_set("array_of_integer :ar, size: 3; @ar[2] = 4")
		expect($outstr).to eq("int ar[3];ar[2] = (4);")
	end

	it "work with 'times' method of static Fixnum" do
		before_input("
			array :mas, with: {type: :integer, size: 3}
			integer :tim, :mit")
		input_set("3.times {|count| tim = count + mit - count}")
		expect($outstr).to eq(clear_str("
			for (int i1=0; i1<(3); i1++) {
				tim = (i1+(mit)-i1);
				}"))
	end

	it "work with 'times' method of dynamic Fixnum" do
		before_input("integer :gvar, :lvar")
		input_set("gvar.times {|count| lvar = 4 + count}")
		expect($outstr).to eq(clear_str("
			for (int i1=0; i1<(gvar); i1++) {
				lvar = (4+i1);
				}"))
	end

	# ToDo
	# it 'generate struct of user class' do
	# 	class TestFirstClass < UserClass
	# 		integer :number
	# 		def test_method
	# 			number.c_assign= 123.5
	# 			return 123.5
	# 		end
	# 	end
	# 	input_set("TestFirstClass.generate_struct")

	# 	expect($outstr).to eq(clear_str("
	# 		typedef struct {
	# 			int number;
	# 			} TestFirstClass;
	# 		float test_method (TestFirstClass *params) {
	# 			(*params).number = 123.5;
	# 			return (123.5)
	# 			}"))
	# end

	# class TestSecondClass < UserClass
	# 	integer :number
	# 	def test_method
	# 		return 123.5 
	# 	end
	# end
	# TestSecondClass.generate_struct
	# TestSecondClass.redefine_users_methods
	# it 'init user class as single instance' do 
	# 	# ToDo
	# end

	# it 'init user class as array' do
	# 	input_set("array :Joys, with: {type: TestSecondClass, size: 5}")
	# 	expect($outstr).to eq("TestSecondClass Joys[5];")
	# end

	# it 'work with user class params' do
	# 	array :Joys, with: {type: TestSecondClass, size: 5}
	# 	input_set("@Joys[0].number = @Joys[1].number + 1")
	# 	expect($outstr).to eq("Joys[0].number = (Joys[1].number+(1));")
	# end

	# it 'work with user class methods' do
	# 	array :Joys, with: {type: TestSecondClass, size: 5}
	# 	input_set("@Joys[1].number = @Joys[1].test_method")
	# 	expect($outstr).to eq("Joys[1].number = test_method(&Joys[1]);")
		
	# 	# ToDo: translate params to methods
	# end

	# it "work with 'each' method of user array" do
	# 	array :Joys, with: {type: TestSecondClass, size: 5}
	# 	input_set("@Joys.each { |joy|
	# 		integer :rybu_test
	# 		joy.number = 3
	# 		rybu_test = joy.number
	# 		}")
	# 	expect($outstr).to eq(clear_str("
	# 		for (int i1=0; i1<5; i1++) {
	# 			int rybu_test;
	# 			Joys[i1].number = (3);
	# 			rybu_test = (Joys[i1].number);
	# 			}"))
	# end


	it "work with conditions" do
		before_input("integer :tim, :mit, :ind")
		input_set("ind=0 if tim <= 0; ind=1 unless tim < 15")
		expect($outstr).to eq(clear_str("
			if ((tim<=(0))) {
				ind = (0);
				}
			if (!((tim<(15)))) {
				ind = (1);
				}"))

		input_set("
			begin
				mit = tim + 2
				if mit==3 then mit = mit-345 end
				tim = 333 if mit!= tim & false
			end unless tim == true")
		expect($outstr).to eq(clear_str("
			if (!((tim==(true)))) {
				mit = (tim+(2));
				int __rubim__rval2 = 0;
				if ((mit==(3))) {
					mit = (mit-(345));
					__rubim__rval2 = (mit-(345));
					}
				if ((mit!=(tim&(false)))) {
					tim = (333);
					}
				}"))
	end

	it "return value of 'if' condition" do
		before_input("integer :tim")
		input_set("tim = if true then 3 end")
		expect($outstr).to eq(clear_str("
			int __rubim__rval1 = 0;
			if ((true)) {
				__rubim__rval1 = (3);
				}
			tim = (__rubim__rval1);"))
	end

	# ToDo: add tests for while/until/loop


end

