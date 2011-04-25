module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name
      when /the home\s?page/
        '/'
      when /the access denied page/
        '/' # access denied should redirect to root url
      when /the registration page/
        new_user_registration_path
      when /the login page/
        new_user_session_path

      when /the new search page/
        new_search_path
      when /the (.+) search page/
        new_group_search_path(Group.find_by_name($1))
      when /the search page for (.+)/
        new_group_search_path(Group.find_by_name($1))

      when /the lings page for (.+)/
        group_lings_path(Group.find_by_name($1))
      when /the ling0s page for (.+)/
        group_lings_depth_path(Group.find_by_name($1), 0)
      when /the ling1s page for (.+)/
        group_lings_depth_path(Group.find_by_name($1), 1)
      when /the properties page for (.+)/
        group_properties_path(Group.find_by_name($1))
      when /the values page for (.+)/
        group_lings_properties_path(Group.find_by_name($1))
      when /the examples page for (.+)/
        group_examples_path(Group.find_by_name($1))
      when /the example values page for (.+)/
        group_examples_lings_properties_path(Group.find_by_name($1))
      when /the memberships page for (.+)/
        group_memberships_path(Group.find_by_name($1))

      when /the group (.*)/
        group_path(Group.find_by_name($1))

      when /the mass assignment page for "(.*)"/
        ling = Ling.find_by_name($1)
        group = ling.group
        set_values_group_ling_path(group, ling)
      when /my group searches/
        group_searches_path(Group.last)

    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      begin
        page_name =~ /the (.*) page/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue Object => e
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)
