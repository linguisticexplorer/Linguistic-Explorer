def rows_per_page rows
  LinguisticExplorer::Application.configure do

    if (ActiveRecord::Base.per_page != rows)
      # regular pagination value
      if(rows == 25)
        ActiveRecord::Base.instance_eval do
          def per_page; 25; end
        end
      elsif(rows == 4)
      # need to test pagination without overloading the db...
        ActiveRecord::Base.instance_eval do
          def per_page; 4; end
        end
      end
    end
  end
end