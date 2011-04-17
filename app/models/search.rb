class Search < ActiveRecord::Base
  include SearchForm
  include SearchResults

  belongs_to :group
  belongs_to :user

  validates_presence_of :user, :group, :name

  attr_accessible :group_id, :user_id

  serialize :query

end