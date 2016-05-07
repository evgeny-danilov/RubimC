#####################################################################
# TEST PREPROCESSOR													#
#####################################################################
RSpec.describe PreProcessor do
	it "add binding when init variables" do
		PreProcessor.execute("boolean :var1")
		expect(PreProcessor.program).to eq("var1 = boolean :var1")

		PreProcessor.execute("bool :var1")
		expect(PreProcessor.program).to eq("var1 = bool :var1")

		PreProcessor.execute("integer :par")
		expect(PreProcessor.program).to eq("par = integer :par")

		PreProcessor.execute("integer par: :integer")
		expect(PreProcessor.program).to eq("par = integer par: :integer")

		PreProcessor.execute("int :@par")
		expect(PreProcessor.program).to eq("@par = int :@par")

		PreProcessor.execute("float :var1, :var2, var3: ADC0, var4: :met, var5: method")
		expect(PreProcessor.program).to eq("var1, var2, var3, var4, var5 = float :var1, :var2, var3: ADC0, var4: :met, var5: method")

		PreProcessor.execute("double :@par")
		expect(PreProcessor.program).to eq("@par = double :@par")

		PreProcessor.execute("string :@par, :$glob")
		expect(PreProcessor.program).to eq("@par, $glob = string :@par, :$glob")
	end

	it "replace '=' to '.c_assign='" do
		PreProcessor.execute("b=c")
		expect(PreProcessor.program).to eq("b.c_assign=c")

		PreProcessor.execute("bG56g = q1")
		expect(PreProcessor.program).to eq("bG56g .c_assign= q1")

		PreProcessor.execute("var12 =!a")
		expect(PreProcessor.program).to eq("var12 .c_assign=!a")

		PreProcessor.execute("var= -rt")
		expect(PreProcessor.program).to eq("var.c_assign= -rt")
	end

	it "dont replace '=' to '.c_assign='" do
		PreProcessor.execute("var(\" = its a string\"")
		expect(PreProcessor.program).to eq("var(\" = its a string\"")

		PreProcessor.execute("b == c")
		expect(PreProcessor.program).to eq("b == c")

		PreProcessor.execute("b += c")
		expect(PreProcessor.program).to eq("b += c")

		PreProcessor.execute("b =~ c")
		expect(PreProcessor.program).to eq("b =~ c")
	end



	it "replace Fixnum before operators on RubimCode::UserVariable.new()" do 
		PreProcessor.execute("num == 3 + 5;")
		expect(PreProcessor.program).to eq("num ==  RubimCode::UserVariable.new(3, 'fixed') +  RubimCode::UserVariable.new(5, 'fixed');")

		PreProcessor.execute(";num45 += n3 / (345.56* 5.4);")
		expect(PreProcessor.program).to eq(";num45 += n3 / ( RubimCode::UserVariable.new(345.56, 'fixed')*  RubimCode::UserVariable.new(5.4, 'fixed'));")

		PreProcessor.execute("tim = +0.79 +(45-3) - num")
		expect(PreProcessor.program).to eq("tim .c_assign= + RubimCode::UserVariable.new(+0.79, 'fixed') +( RubimCode::UserVariable.new(45, 'fixed')- RubimCode::UserVariable.new(3, 'fixed')) - num")

		PreProcessor.execute("mit = mit +1")
		expect(PreProcessor.program).to eq("mit .c_assign= mit + RubimCode::UserVariable.new(+1, 'fixed')")

		PreProcessor.execute("mit = mit -1")
		expect(PreProcessor.program).to eq("mit .c_assign= mit - RubimCode::UserVariable.new(1, 'fixed')")

		PreProcessor.execute("mit = mit %1")
		expect(PreProcessor.program).to eq("mit .c_assign= mit %1")
	end

	it "replace Fixnum before methods on RubimCode::UserVariable.new()" do 
		PreProcessor.execute("28.times do |count3|")
		expect(PreProcessor.program).to eq(" RubimCode::UserVariable.new(28, 'fixed').times do |count3|")
	end



	it "replace if modify expression" do
		PreProcessor.execute("puts 'qwe' if tmp_cond\n")
		expect(PreProcessor.program).to eq("puts 'qwe' if RubimCode.rubim_ifmod tmp_cond; RubimCode.rubim_end;\n")

		PreProcessor.execute("puts 'qwe' if tmp_cond; puts 'asd'")
		expect(PreProcessor.program).to eq("puts 'qwe' if RubimCode.rubim_ifmod tmp_cond; RubimCode.rubim_end;; puts 'asd'")

		PreProcessor.execute("begin puts 'qwe' if tmp_cond end")
		expect(PreProcessor.program).to eq("begin puts 'qwe' if RubimCode.rubim_ifmod tmp_cond ; RubimCode.rubim_end;end")

		PreProcessor.execute(("
			begin
				puts 'qwe'
			end if tmp_cond\n"))
		expect(PreProcessor.program).to eq(("
			begin
				puts 'qwe'
			end if RubimCode.rubim_ifmod tmp_cond; RubimCode.rubim_end;\n"))
	end

	it "replace if expression" do
		PreProcessor.execute("if tmp_cond then puts 'qwe' end")
		expect(PreProcessor.program).to eq("RubimCode.rubim_if tmp_cond  do; puts 'qwe' end")

		PreProcessor.execute("
			if tmp_cond
				puts 'qwe'
			end")
		expect(PreProcessor.program).to eq("
			RubimCode.rubim_if tmp_cond do
				puts 'qwe'
			end")

		PreProcessor.execute("
			if tmp_cond then
				puts 'qwe'
			end")
		expect(PreProcessor.program).to eq("
			RubimCode.rubim_if tmp_cond  do;
				puts 'qwe'
			end")
	end

	it "replace then, else and elsif keywords" do
		PreProcessor.execute("
			if tmp_cond
				puts 'qwe'
			elsif tmp_cond2 then
				puts 'ewq'
			else
				puts 'ewq'
			end")
		expect(PreProcessor.program).to eq("
			RubimCode.rubim_if tmp_cond do
				puts 'qwe'
			RubimCode.rubim_elsif tmp_cond2 ;
				puts 'ewq'
			RubimCode.rubim_else
				puts 'ewq'
			end")
	end

	it "replace next and break control instructions" do
		PreProcessor.execute("next")
		expect(PreProcessor.program).to eq("RubimCode.rubim_next")

		PreProcessor.execute("break")
		expect(PreProcessor.program).to eq("RubimCode.rubim_break")
	end

	it "replace unless modify expression" do
		PreProcessor.execute("puts 'qwe' unless tmp_cond")
		expect(PreProcessor.program).to eq("puts 'qwe' if RubimCode.rubim_unlessmod tmp_cond; RubimCode.rubim_end;")

		PreProcessor.execute("puts 'qwe' unless (tmp_cond); puts 'asd'")
		expect(PreProcessor.program).to eq("puts 'qwe' if RubimCode.rubim_unlessmod (tmp_cond); RubimCode.rubim_end;; puts 'asd'")

		PreProcessor.execute("begin puts 'qwe' unless tmp_cond end")
		expect(PreProcessor.program).to eq("begin puts 'qwe' if RubimCode.rubim_unlessmod tmp_cond ; RubimCode.rubim_end;end")

		PreProcessor.execute(("
			begin
				puts 'qwe'
			end unless tmp_cond"))
		expect(PreProcessor.program).to eq(("
			begin
				puts 'qwe'
			end if RubimCode.rubim_unlessmod tmp_cond; RubimCode.rubim_end;"))
	end

	it "replace unless expression" do
		PreProcessor.execute("unless tmp_cond then puts 'qwe' end")
		expect(PreProcessor.program).to eq("RubimCode.rubim_unless tmp_cond  do; puts 'qwe' end")

		PreProcessor.execute("
			unless tmp_cond
				puts 'qwe'
			end")
		expect(PreProcessor.program).to eq("
			RubimCode.rubim_unless tmp_cond do
				puts 'qwe'
			end")

		PreProcessor.execute("
			unless (true) then
				puts 'qwe'
			end")
		expect(PreProcessor.program).to eq("
			RubimCode.rubim_unless (RubimCode::UserVariable.new(true, 'fixed'))  do;
				puts 'qwe'
			end")
	end



	it "replace while modify expression" do
		PreProcessor.execute("puts 'qwe' while true")
		expect(PreProcessor.program).to eq("puts 'qwe' if RubimCode.rubim_begin; RubimCode.rubim_whilemod RubimCode::UserVariable.new(true, 'fixed')")

		PreProcessor.execute("
			begin
				puts 'qwe'
			end while (!i)\n")
		expect(PreProcessor.program).to eq("
			begin
				puts 'qwe'
			end if RubimCode.rubim_begin; RubimCode.rubim_whilemod (!i)\n")
	end

	it "replace while expression" do
		PreProcessor.execute("while (tmp_cond>i and a!=b) do puts 'qwe' end")
		expect(PreProcessor.program).to eq("RubimCode.rubim_while (tmp_cond>i and a!=b) do puts 'qwe' end")

		PreProcessor.execute("
			while true 
				puts 'qwe'
			end")
		expect(PreProcessor.program).to eq("
			RubimCode.rubim_while RubimCode::UserVariable.new(true, 'fixed')  do
				puts 'qwe'
			end")

		PreProcessor.execute("
			while (tmp_cond)  do ;
				puts 'qwe'
			end")
		expect(PreProcessor.program).to eq("
			RubimCode.rubim_while (tmp_cond)  do ;
				puts 'qwe'
			end")
	end

	it "replace until modify expression" do
		PreProcessor.execute("puts 'qwe' until tmp_cond\n")
		expect(PreProcessor.program).to eq("puts 'qwe' if RubimCode.rubim_begin; RubimCode.rubim_untilmod tmp_cond\n")
	end

	it "replace until expression" do
		PreProcessor.execute("until (tmp_cond>i and a!=b) do puts 'qwe' end")
		expect(PreProcessor.program).to eq("RubimCode.rubim_until (tmp_cond>i and a!=b) do puts 'qwe' end")
	end

	it "replace loop expression" do
		PreProcessor.execute("loop do puts 'qwe' end")
		expect(PreProcessor.program).to eq("RubimCode.rubim_loop do puts 'qwe' end")
	end

end
