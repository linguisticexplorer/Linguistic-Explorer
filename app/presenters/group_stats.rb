module GroupStats

  def lings_in_group(depth = 0)
    @lings_at_depth = Hash.new if @lings_at_depth.nil?
    @lings_at_depth[depth] ||= self.lings.at_depth(depth)
    @lings_at_depth[depth].count(:id)
  end

  def props_in_group
    self.properties.count(:id)
  end

  def ling_props_in_group
    @lings_prop_total ||= self.lings_properties.count(:id)
  end

  def examples_in_group
    @ex_total ||= self.examples.count(:id)
  end

  def members_in_group
    @mem_total ||= self.memberships.count(:id)
  end

  def lings_with_property_quota(depth)
    self.lings_properties.
    # where(:ling_id => @lings_at_depth[depth]).
    group(:ling_id).
    having(["COUNT(property_id) >= ?", props_in_group]).count.size
  end

  def props_with_lings_quota
    self.lings_properties.
      group(:property_id).having(["COUNT(ling_id) >= ?", lings_in_group]).
      count.size
  end



end