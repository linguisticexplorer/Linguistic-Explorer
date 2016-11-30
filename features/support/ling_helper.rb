module LingHelper
  def add_membership2lings_role_from_table(membership, role, table)
    table.hashes.each do |hash|
      lings = Ling.where(name: hash['name'])
      lings.each do |ling|
        membership.add_role(role, ling)
      end
    end
  end
end

World(LingHelper)