namespace :sswl do
  require 'iconv'

  i = Iconv.new('UTF-8','LATIN1')

  desc "This task fixes encoding problems with property description"
  task :fix_property_examples => :environment do

    properties = Property.all

    properties.each do |prop|
      prop.description = i.iconv(prop.description) unless prop.description == nil
      prop.save!
    end

  end
end
