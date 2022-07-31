# require 'pry'

RSpec.describe "Scripts" do
  describe "nwnsc" do
	  it "compiles successfully" do
		scripts_compiled = system("tools/linux/nwnsc/nwnsc -oe -i src/nss -i nwn-base-scripts -b spec_output src/nss/*.nss")
		
		expect(scripts_compiled)
	  end
  end
end