#!/usr/local/bin/ruby -w

require 'net/http'

%w[
  StoredValue.csv
  ExampleLingsProperty.csv
  Example.csv
  LingsProperty.csv
  Category.csv
  Property.csv
  Ling.csv
  Membership.csv
  Group.csv
  User.csv
].each do |csv|
    File.open(File.join("doc", "data", csv), "w") do |f|
      f.puts Net::HTTP.get URI.parse("http://cs.nyu.edu/cs/faculty/shasha/papers/#{csv}")
    end
  end

# http://cs.nyu.edu/cs/faculty/shasha/papers/ExampleLingPropVal.csv
# http://cs.nyu.edu/cs/faculty/shasha/papers/Category.csv
# http://cs.nyu.edu/cs/faculty/shasha/papers/Example.csv
# http://cs.nyu.edu/cs/faculty/shasha/papers/LingPropVal.csv
# http://cs.nyu.edu/cs/faculty/shasha/papers/Property.csv
# http://cs.nyu.edu/cs/faculty/shasha/papers/Ling.csv
# http://cs.nyu.edu/cs/faculty/shasha/papers/User.csv
# http://cs.nyu.edu/cs/faculty/shasha/papers/Group.csv
# http://cs.nyu.edu/cs/faculty/shasha/papers/GroupMembership.csv