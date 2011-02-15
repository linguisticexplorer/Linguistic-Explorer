module GroupsHelper

  def groups_options
    Group.all.map { |g| [g.name, g.id] }
  end
end