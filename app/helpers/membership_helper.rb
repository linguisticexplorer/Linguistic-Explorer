module MembershipHelper
  
  def describe_role
    # find out for which resources is expert
    role = @membership.role.titleize

    if @membership.is_expert?
      role << " in #{@lings.size} #{current_group.ling0_name.pluralize}"
    end

    role
  end

  def resources_list
    @lings.map do |ling|
      link_to ling.name, [current_group, ling]
    end.join("; ").html_safe
  end

end