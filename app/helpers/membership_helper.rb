module MembershipHelper
  
  def describe_role
    # find out for which resources is expert
    @membership.role.titleize
  end

  def resources_list
    @resources ||= @lings.map do |ling|
      link_to ling.name, [current_group, ling]
    end
  end

  def resources_names
    @resources.join("; ").html_safe
  end

  def lings_name(resource_list=[])
    resource_list.map { |ling| ling.name }.join(', ')
  end

end