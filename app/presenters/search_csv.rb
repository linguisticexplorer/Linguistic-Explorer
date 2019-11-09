require 'csv'
class SearchCSV
  include SearchColumns

  def initialize(search)
    @search = search
  end

  def to_csv
    CSV.generate do |csv|
      # header row
      csv << result_headers.map { |header| header[:value].call(@search.group) }

      # data rows
      @search.results.each do |result|
        csv << parent_data(result.parent) + child_data(result.child)
      end
    end
  end

  def parent_data(parent)
    parent_columns.map { |col| row_methods[col].call(parent) }
  end

  def child_data(child)
    child_columns.map { |col| row_methods[col].call(child) }
  end

  def row_methods
    @row_methods ||= {
      :ling_0     => lambda { |v| v.ling.name },
      :ling_1     => lambda { |v| v.ling.name },
      :property_0 => lambda { |v| v.property.name },
      :property_1 => lambda { |v| v.property.name },
      :value_0    => lambda { |v| v.value  },
      :value_1    => lambda { |v| v.value  },
      :example_0  => lambda { |v| v.examples.map(&:name).join("; ") },
      :example_1  => lambda { |v| v.examples.map(&:name).join("- ") }
    }
  end

end