module GroupStats

  attr_accessor :lings_info, :props_info

  # Infos preload returning self for chaining
  def loadInfos
    @lings_info, @props_info = {}, {}
    lings_with_all_property_quotas || props_with_all_ling_quotas
    self
  end

  def lings_in_group
    @lings_total ||= Ling.in_group(self).count(:id)
  end

  def props_in_group
    @props_total ||= Property.in_group(self).count(:id)
  end

  def ling_props_in_group
    @lings_prop_total ||= LingsProperty.in_group(self).count(:id)
  end

  def examples_in_group
    @ex_total ||= Example.where(:group_id => self.id).count(:id)
  end

  def members_in_group
    @mem_total ||= Membership.where(:group_id => self.id).count(:id)
  end

  def lings_with_all_property_quotas
    @lings_info.tap do |lings|
      (0..10).each do |step|
        lings[step*10] ||= lings_with_property_quota(step*10).size
      end
    end
  end

  def props_with_all_ling_quotas
    @props_info.tap do |props|
      (0..10).each do |step|
        props[step*10] ||= props_with_lings_quota(step*10).size
      end
    end
  end

  private

  def lings_with_property_quota(quota=90)
    LingsProperty.in_group(self).group(:ling_id).having(["COUNT(property_id) >= ?", props_in_group * quota / 100]).count
  end

  def props_with_lings_quota(quota=90)
    LingsProperty.in_group(self).group(:property_id).having(["COUNT(ling_id) >= ?", lings_in_group * quota / 100]).count
  end



end