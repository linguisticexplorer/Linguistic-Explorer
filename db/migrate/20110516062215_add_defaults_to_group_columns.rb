class AddDefaultsToGroupColumns < ActiveRecord::Migration
  COLUMNS = {
    :ling0_name                   => {:type => :string,  :default => "Ling"         },
    :ling1_name                   => {:type => :string,  :default => "Linglet"      },
    :property_name                => {:type => :string,  :default => "Property"     },
    :category_name                => {:type => :string,  :default => "Category"     },
    :lings_property_name          => {:type => :string,  :default => "Value"        },
    :example_name                 => {:type => :string,  :default => "Example"      },
    :examples_lings_property_name => {:type => :string,  :default => "Example Value"},
    :privacy                      => {:type => :string,  :default => Group::PUBLIC  },
    :depth_maximum                => {:type => :integer, :default => Group::MAXIMUM_ASSIGNABLE_DEPTH}
  }
  def self.up
    COLUMNS.each do |(key, options)|
      change_column :groups, key, options[:type], :default => options[:default]
    end
  end

  def self.down
    COLUMNS.each do |(key, options)|
      change_column :groups, key, options[:type], :default => ""
    end
  end
end

