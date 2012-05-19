module GroupStats

  def lings_in_group
    Ling.in_group(self).count(:id)
  end

  def props_in_group
    Property.in_group(self).count(:id)
  end

  def lings_with_all_property_quotas
    {}.tap do |quotas|
      (1..10).each do |step|
        quotas[step*10] = lings_with_property_quota(step*10)
      end
    end
  end

  def props_with_all_ling_quotas
    {}.tap do |quotas|
      (1..10).each do |step|
        quotas[step*10] = props_with_lings_quota(step*10)
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