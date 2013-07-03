desc "This task fixes repetition of the words gloos, words,"
task :fix_examples => :environment do
	examples = Example.all

	examples.each do |example|
		values = example.stored_values
		values.each do |value|
			key = value.key
			if key.downcase == value.value[0,key.length].downcase && value.value.length > key.length
				#second condition for placeholders, i.e. for key comment, a placeholder COMMENT is put for testing
				value.value = value.value[key.length + 1, value.value.length].strip
				value.save!
			end
		end
	end
end