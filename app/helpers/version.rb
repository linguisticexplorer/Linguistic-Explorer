module Version

	  TARGET = "#{Rails.root}/app/helpers/v"

	  def self.get
	  	File.open(TARGET, "r") do |f|
	  		v = f.read().split(/\n/)
  			return v[0..-2].join('.') + "-" + v[-1] 
  		end 
	  end

	  VERSION = self.get

	  def self.set(v)
	    File.open(TARGET, "w") do |f|
  			f.write(v.split(/[.-]/).join("\n"))
  		end 
	  end

	  def self.bump(c)
	  	v = []

	  	File.open(TARGET, "r") do |f|
	  		v = f.read().split(/\n/)
	  	end
	 
	   	v[c] = (v[c].to_i + 1).to_s

		for x in ((c+1)...v.length)
			v[x] = 0
		end

	    File.open(TARGET, "w") do |f|
  			f.write(v.split(/[.-]/).join("\n") )
  		end 
	  end

end