Given /^the following forum groups:$/ do |table|
  table.hashes.each do |attrs|
    next if ForumGroup.find_by_title attrs[:title]
    create_forum_group(attrs)
  end
end

Given /^the following "([^\"]*)" forums:$/ do |group_title, table|
  forum_group = ForumGroup.find_by_title(group_title)
  table.hashes.each do |attrs|
    next if Forum.find_by_title attrs[:title]
    create_forum(attrs.merge(:forum_group => forum_group))
  end
end

Given /^the following "([^\"]*)" topics from "([^\"]*)":$/ do |forum_title, email, table|
  forum = Forum.find_by_title(forum_title)
  password  = "hunter2"
  user     = User.find_by_email(email) || create_user(:email => email, :password => password)
  table.hashes.each do |attrs|
    next if Topic.find_by_title attrs[:title]
    create_topic(attrs.merge(:forum => forum, :user => user))
  end
end