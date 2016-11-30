module LinkHelper

  def link_to_new_group_ling ling, depth, options={}, &block
    if can?(:create, ling)
      link_to new_group_ling_path(current_group, :depth => depth), options, &block
    else
      options[:onclick] = "$('#create_ling_modal').modal('show');"
      link_to "#", options, &block
    end
  end

  def link_to_delete_ling ling, options={}, &block
    if can?(:destroy, ling)
      link_to [current_group, ling], options, &block
    else
      options[:confirm] = nil
      options[:method] = nil
      options[:onclick] = "$('#delete_ling_modal').modal('show');"
      link_to "#", options, &block
    end
  end

end