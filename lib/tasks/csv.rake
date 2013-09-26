desc "This task creates a csv file of all languages and their properties"
task :make_csv => :environment do
	def get_value(x,y)
			x.each do |prop|
				if prop.property_id == y
					return prop.value
				end
			end
  			return "ns"
    end

	file = File.open("languages.csv", "w")
	all_properties = Property.all
	file.write("Language") 

	all_properties.each do |prop|
		file.write(", " + prop.name)
	end

	file.write("\n")

	Ling.all.each do |ling|
		string = ling.name
		all_properties.each do |prop|
			string += ", " + get_value(ling.lings_properties, prop.id)
		end
		file.write(string + "\n")
		puts string
	end

	file.close unless file == nil

end