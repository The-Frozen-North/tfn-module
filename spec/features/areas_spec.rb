require 'pry'
require 'json'

RSpec.configure do |rspec|
  rspec.expect_with :rspec do |c|
    c.max_formatted_output_length = nil
  end
end

RSpec.describe "Areas" do
  describe "validate" do
	  it "encounter resref exists" do
		encounter_resrefs = Dir.children("src/ute").each { |e| e.slice! ".ute.json" }
		areas_with_invalid_resrefs = {}
		
		area_git_path = "src/git"
		Dir.children(area_git_path).each do |file_name|
		  file = File.open("#{area_git_path}/#{file_name}", 'r')
		  
		  json = JSON.load file
		  
		  if json["VarTable"].nil? || json["VarTable"]["value"].nil?
			  file.close
			  next
		  end
		  
		  json["VarTable"]["value"].each do |area_variable|
			name = area_variable["Name"]["value"]
			
			# get the last digit of a spawn target, e.g. 2 from spawn2
			spawn_target = name[-1]
			
			value = area_variable["Value"]["value"]
			
			next unless value.nil? || name.tr("0-9", "") == "random"
			
			unless encounter_resrefs.include? value
				areas_with_invalid_resrefs[file_name] ||= []
				areas_with_invalid_resrefs[file_name] << "#{name}: #{value}"
			end
		  end

		  file.close
		end
		
		expect(areas_with_invalid_resrefs).to be_empty
	  end
  end
end