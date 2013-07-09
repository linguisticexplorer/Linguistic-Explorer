desc "This task changes all groups' display_style values to 'linguistic'"
task :display_style_to_linguistic => :environment do
	
	Group.all.each do |group|
		group.display_style = 'linguistic'
		group.save!
	end

end