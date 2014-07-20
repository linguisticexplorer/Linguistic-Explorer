module ExampleHelper

  def storable_rows(columns)
    cleaned = []
    row     = []
    index   = 0
    @example.storable_keys.each do |key|
      if key.downcase != "description"
        row << key
        index = index + 1
        if index % columns == 0
          # save the current row
          cleaned << row
          # create a new row
          row = []
        end
       end
    end
    return cleaned
  end

end