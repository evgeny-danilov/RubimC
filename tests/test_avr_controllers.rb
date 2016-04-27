#####################################################################
# TEST AVR Controllers												#
#####################################################################
require_relative "../lib/avr/attiny13.rb"

class TinyController < AVR_attiny13; end

RSpec.describe TinyController do
	before :each do
		RubimCode.level = 1
		$outstr = ''
		$test_mcu = TinyController.new
	end

	it "work with output function" do 
		input_set("output :led, port: :B, pin: 3")
		expect($outstr).to eq("DDRB |= 1<<(3);")

		input_set("output :led, port: :F, pin: 0")
		expect($outstr).to eq("Custom Error") 

		input_set("output :led, port: :B, pin: 30")
		expect($outstr).to eq("Custom Error") 
	end
end


