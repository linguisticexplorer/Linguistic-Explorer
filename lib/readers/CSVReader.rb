require 'csv'

class CSVReader

  attr_accessor :csv_path

  def initialize path
    @csv_path = path
  end

  def for_each
    CSV.foreach(@csv_path, :headers => true) do |row|
      yield(row)
    end
  end

  def size
    (CSV.read(@csv_path).length) -1
  end
end
