class StoredValue < ActiveRecord::Base
  belongs_to :storable, :polymorphic => true
  validates_presence_of :key, :value, :storable
  validates_existence_of :storable
  validate :key_is_allowed_from_storable

  def key_is_allowed_from_storable
    if self.storable && !self.storable.storable_keys.include?(self.key)
      type_name = (self.storable.reflect_on_all_associations(:belongs_to).include?(:group) ? storable.grouped_name : storable.class.to_s)
      errors[:key] << "must be a storable key valid for #{type_name}"
    end
  end
end
