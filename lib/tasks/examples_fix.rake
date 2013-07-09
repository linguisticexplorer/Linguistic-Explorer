#!/bin/env ruby
# encoding: utf-8

require 'iconv'

desc "This task fixes repetition of the words gloss, translation, etc."
task :fix_examples => :environment do

	examples = Example.all

	examples.each do |example|
		entries = example.stored_values
		entries.each do |entry|
			key = entry.key
			if key.downcase == entry.value[0,key.length].downcase && entry.value.length > key.length
				#second condition for placeholders, i.e. for key comment, a placeholder COMMENT is put for testing
				if entry.value.length == (key.length + 1)
					entry.value = "None"
					#to pass empty field validation
				else 
					entry.value = entry.value[key.length + 1, entry.value.length].strip
				end
			end
			entry.value = Iconv.conv('latin1', 'utf-8', entry.value)
			entry.save!
		end
	end
end