namespace :db do
  desc "create properties from names file"
  task :load_properties => :environment do
    f = File.open(Rails.root.join("doc", "property-names.txt"), "r")
    f.readlines.each do |name|
      attrs = { :name => name.strip, :category => "Grammar" }
      next if Property.exists?(attrs)
      puts "Creating property '#{name.strip}'"
      Property.create!(attrs)
    end
  end

  task :load_languages => :environment do
    f = File.open(Rails.root.join("doc", "data", "language-names.txt"), "r")
    f.readlines.each do |name|
      attrs = { :name => name.strip }
      next if Ling.exists?(attrs)
      puts "Creating ling '#{name.strip}'"
      Ling.create!(attrs)
    end
  end

  desc "create doc file from html"
  task :doc_file_from_html => :environment do
    w = File.open(Rails.root.join("doc", "data", "language-names.txt"), "w")
    r = File.open(Rails.root.join("doc", "data", "language-options.txt"), "r")

    r.readlines.each do |l|
      line = l.gsub(/\<[^\>]*\>/, "")
      w << line
    end
  end
  
  task :set_property_values_on_lings_properties => :environment do
    LingsProperty.find_in_batches do |lps|
      lps.each { |lp| lp.set_property_value; lp.save! }
    end
  end

end