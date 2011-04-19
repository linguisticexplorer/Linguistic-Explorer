class Search < ActiveRecord::Base
  include SearchForm
  include SearchResults
  include JsonAccessible

  belongs_to :group
  belongs_to :user

  validates_presence_of :user, :group, :name

  serialize :query
  serialize :parent_ids
  serialize :child_ids

  json_accessor :query, :parent_ids, :child_ids

end