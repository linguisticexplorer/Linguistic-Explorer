module Exceptions

  RESULTS_FLATTEN_THRESHOLD = 100000
  RESULTS_CROSS_THRESHOLD = 3

  class ResultsTooBigError < StandardError
    Rails.logger.debug "ResultsTooBigError raised!."
  end
end