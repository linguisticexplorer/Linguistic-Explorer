require "#{Rails.root}/app/helpers/version"

namespace :version do 

	desc "Set specific version"
	task :set do 
		version = ARGV.last
		version = version.split('.')
		Version.set(version[0], version[1], version[2], version[3])
		task version.to_sym do; end
	end

	desc "Increment major"
	task :major do 
		Version.bump('major')
	end

	desc "Increment minor"
	task :minor do 
		Version.bump('minor')
	end

	desc "Increment build"
	task :build do 
		Version.bump('build')
	end

	desc "Increment patch"
	task :patch do 
		Version.bump('patch')
	end

end
