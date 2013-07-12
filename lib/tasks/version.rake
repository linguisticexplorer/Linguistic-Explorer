require "#{Rails.root}/app/helpers/version"

namespace :version do 

	desc "Sete specific version"
	task :set do 
		version = ARGV.last
		Version.set(version)
		task version.to_sym do; end
	end

	desc "Increment major"
	task :major do 
		Version.bump(0)
	end

	desc "Increment minor"
	task :minor do 
		Version.bump(1)
	end

	desc "Increment build"
	task :build do 
		Version.bump(2)
	end

	desc "Increment patch"
	task :patch do 
		Version.bump(3)
	end

end