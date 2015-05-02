module Exceptions

  class SearchError < StandardError
    def message
      "An error occurred during the search. If error persist please contact the Administrator"
    end
  end

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
      "An error occurred during the search. Please select less Properties for Cross"
    end
  end

  class ResultAtLeastTwoForCrossError < ResultSearchError
    def message
      "An error occurred during the search. Please select at least 2 Properties for Cross"
    end
  end

  class ResultAtLeastTwoForCompareError < ResultSearchError
    def message
      "An error occurred during the search. Please select at least 2 Lings for Compare"
    end
  end

  class ResultTooManyForCompareError < ResultSearchError
    def message
      "An error occurred during the search. Please select less Lings for Compare"
    end
  end

  class ResultTooManyForImplicationError < ResultSearchError
    def message
      "An error occurred during the search. Please select less Properties for Implication"
    end
  end

  class ResultTooManyForLegacyClustering < ResultSearchError
    def message
      "An error occurred during the search. Please select less Properties for the Similarity Tree"
    end
  end

  class AccessDenied < StandardError
    def message
      "The member has not the permissions to access the resource"
    end
  end
  
end