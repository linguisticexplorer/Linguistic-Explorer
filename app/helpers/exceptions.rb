module Exceptions

  class ResultSearchError < StandardError
    def message
      "An error occurred during the search. If error persist please contact the Administrator"
    end
  end

  class ResultTooBigError < ResultSearchError
    def message
      "An error occurred during the search. Please focus your search."
    end
  end

  class ResultTooManyForCrossError < ResultSearchError
    def message
      "An error occurred during the search. Please select less than #{Search::RESULTS_CROSS_THRESHOLD} Properties for Cross"
    end
  end

  class ResultAtLeastTwoForCrossError < ResultSearchError
    def message
      "An error occurred during the search. Please select at least 2 Properties for Cross"
    end
  end
end